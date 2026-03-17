extends CharacterBody2D

class_name Player 

@export var jump_strength :int = 1250
@export var speed_per_second :int = 3000
@export var max_speed :int = 450
@export var jump_buffer_time :float = 0.1
@export var wall_gravity_scale :float = 0.15
@export_range(0,100,1.0) var peer_lerp_speed :float = 30

@onready var audio_files :Dictionary[String, AudioStreamMP3]= {
	"running" : preload("uid://cap73awyf8ake"),
	"jump" : preload("uid://we1luimcp6fb"),
	"die" : preload("uid://dafct6iqadbur"),
}

@onready var dust_particles :GPUParticles2D = $dust_particles
@onready var jump_particles :GPUParticles2D = $jump_particles
@onready var death_particles :GPUParticles2D = $die_particles
@onready var audio_stream :AudioStreamPlayer = $AudioStreamPlayer
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D

@onready var multi_sync :MultiplayerSynchronizer = $MultiplayerSynchronizer
@export var sync_position: Vector2 = Vector2.ZERO
@export var sync_velocity: Vector2 = Vector2.ZERO

var dead :bool = false #TEMPOARY
var double_jumped :bool = false
var air_time :float = 0

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		global_position = global_position.lerp(sync_position, delta * peer_lerp_speed)
		return
	else:
		sync_velocity = velocity
		sync_position = global_position
	
	if dead:
		var col :CollisionShape2D = $CollisionShape2D
		col.disabled = true
		_limit_horizontal_velocity(max_speed * 4)
		_reduce_horizontal_velocity(delta, speed_per_second / 20.0)
		_apply_gravity(delta, 0.65)
		move_and_slide()
		return
	
	var move_axis :float = Input.get_axis("move_left", "move_right")
	_limit_horizontal_velocity(max_speed)
	if move_axis == 0:
		_reduce_horizontal_velocity(delta, speed_per_second)
	
	if is_on_floor() or is_on_wall():
		double_jumped = false
		air_time = 0
	else:
		air_time += delta
		
	#Has to be after to ensure air_time is igonered if player jumps while on floor.
	if Input.is_action_just_pressed("jump"):
		_attempt_jump()

	velocity.x += move_axis * speed_per_second * delta

	if is_on_wall_only() && velocity.y > 0:
		anim.play("Wall_Jump")
		_apply_gravity(delta, wall_gravity_scale)
	else:
		_apply_gravity(delta)
	

	move_and_slide()
	_update_anim(move_axis)

func _attempt_jump() -> void:
	if is_on_wall_only():
		velocity.y = -jump_strength * 0.85
		if anim.flip_h:
			velocity.x = max_speed
		else:
			velocity.x = -max_speed
		air_time = jump_buffer_time
		anim.flip_h = !anim.flip_h
		jump_particles.restart(false)
		audio_stream.stream = audio_files["jump"]
		audio_stream.volume_db = -20
		audio_stream.pitch_scale = randf_range(0.8, 1.1)
		audio_stream.play()
		StatisticManager.add_value("wall_jump", 1)
	
	elif is_on_floor() or air_time < jump_buffer_time:
		jump_particles.restart(false)
		air_time = jump_buffer_time
		velocity.y = -jump_strength
		audio_stream.stream = audio_files["jump"]
		audio_stream.volume_db = -20
		audio_stream.pitch_scale = randf_range(0.8, 1.1)
		audio_stream.play()
		StatisticManager.add_value("ground_jump", 1)

	elif !double_jumped:
		double_jumped = true
		velocity.y = -jump_strength * 0.85
		anim.play("Double_Jump")
		jump_particles.restart(false)
		audio_stream.stream = audio_files["jump"]
		audio_stream.volume_db = -20
		audio_stream.pitch_scale = randf_range(0.8, 1.1)
		audio_stream.play()
		StatisticManager.add_value("double_jump", 1)

func _apply_gravity(delta: float, gravity_scale: float = 1) -> void:
	velocity += get_gravity() * delta * gravity_scale

func _limit_horizontal_velocity(max_vel: int) -> void:
	if velocity.x > 20:
		if velocity.x > max_vel:
			velocity.x = max_vel
	elif velocity.x < -20:
		if velocity.x < -max_vel:
			velocity.x = -max_vel
	else:
		velocity.x = 0

func _reduce_horizontal_velocity(delta: float, amount_per_second: float) -> void:
	if velocity.x < -20:
		velocity.x += amount_per_second * delta
	elif velocity.x > 20:
		velocity.x -= amount_per_second * delta
	else:
		velocity.x = 0

@rpc("any_peer", "call_local","reliable")
func reset_player(gpos:Vector2) -> void:
	dead = false
	anim.play("Idle")
	death_particles.emitting = false
	var col :CollisionShape2D = $CollisionShape2D
	col.disabled = false
	rotation = 0
	velocity = Vector2.ZERO
	global_position = gpos

func _die() -> void: #TEMPOARY
	print("player dying")
	dead = true
	GameManager.rpc("player_died")
	death_particles.restart()
	anim.play("Die")
	audio_stream.stream = audio_files["die"]
	audio_stream.volume_db = -8
	audio_stream.pitch_scale = randf_range(0.9, 1.1)
	audio_stream.play()

func hit(vec: Vector2) -> void:
	if is_multiplayer_authority():
		velocity = vec * max_speed * 1.5
		_die()

func _update_anim(move_axis: float) -> void:
	if dead:
		return
		
	if move_axis > 0:
		anim.flip_h = false
	if move_axis < 0:
		anim.flip_h = true

	if is_on_floor():
		if move_axis == 0:
			anim.play("Idle")
			dust_particles.emitting = false
			audio_stream.stop()
		else:
			anim.play("Run")
			dust_particles.emitting = true
			if audio_stream.stream != audio_files["running"] or !audio_stream.playing:
				audio_stream.stream = audio_files["running"]
				audio_stream.volume_db = -14
				audio_stream.pitch_scale = randf_range(0.9, 1.1)
				audio_stream.play()
	elif !is_on_wall_only():
		if velocity.y < 0 && !double_jumped:
			dust_particles.emitting = false
			anim.play("Jump")

		if velocity.y > 0:
			anim.play("Fall")
			dust_particles.emitting = false
