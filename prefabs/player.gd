extends CharacterBody2D

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@export var jump_strength :int = 1250
@export var speed_per_second :int = 3000
@export var max_speed :int = 450
@export var jump_buffer_time :float = 0.1
@export var wall_gravity_scale :float = 0.15

@onready var audio_files = {
	"running" : preload("res://assets/audio/sfx/fast_footsteps.mp3"),
	"jump" : preload("res://assets/audio/sfx/jump.mp3"),
	"die" : preload("res://assets/audio/sfx/death.mp3"),
}

@onready var dust_particles = $dust_particles
@onready var jump_particles = $jump_particles
@onready var death_particles = $die_particles
@onready var audio_stream = $AudioStreamPlayer

var player_idx := 0:
	set(value):
		player_idx = value
		if skin_outlines:
			$AnimatedSprite2D.material.set_shader_parameter("color", player_colors[player_idx])
		if uniqe_skins:
			$AnimatedSprite2D.sprite_frames = $AnimatedSprite2D.skin_sprites[player_skins[player_idx]]
			
const uniqe_skins := false
const skin_outlines := true

const player_skins :Array[String] = [
	"Osvald",
	"Tiki",
	"Castro",
	"Edward",
]

const player_colors :Array[Color]= [
	Color("59ff007c"),
	Color("ff2f1cb5"),
	Color("ff00d9b5"),
	Color("ffd000b5"),
]
const controls :Array[Dictionary] = [
	{
		"left" : "move_left",
		"right" : "move_right",
		"jump" : "jump",
	},
	{
		"left" : "move_left_p2",
		"right" : "move_right_p2",
		"jump" : "jump_p2",
	},
	{
		"left" : "move_left_p3",
		"right" : "move_right_p3",
		"jump" : "jump_p3",
	},
	{
		"left" : "move_left_p4",
		"right" : "move_right_p4",
		"jump" : "jump_p4",
	},
]

var dead = false #TEMPOARY
var double_jumped :bool = false
var air_time :float = 0


func _physics_process(delta: float) -> void:
	if dead:
		var col = $CollisionShape2D
		col.disabled = true
		_limit_horizontal_velocity(max_speed * 4)
		_reduce_horizontal_velocity(delta, speed_per_second / 20)
		_apply_gravity(delta, 0.65)
		move_and_slide()
		return
	
	var m = Input.get_axis(controls[player_idx]["left"], controls[player_idx]["right"])
	_limit_horizontal_velocity(max_speed)
	if m == 0:
		_reduce_horizontal_velocity(delta, speed_per_second)
	
	if Input.is_action_just_pressed(controls[player_idx]["jump"]):
		_attempt_jump()
	
	if is_on_floor() or is_on_wall():
		double_jumped = false
		air_time = 0
	else:
		air_time += delta

	velocity.x += m * speed_per_second * delta

	if is_on_wall_only() && velocity.y > 0:
		anim.play("Wall_Jump")
		_apply_gravity(delta, wall_gravity_scale)
	else:
		_apply_gravity(delta)
	

	move_and_slide()
	_update_anim(m)

func _attempt_jump():
	if is_on_wall_only():
		velocity.y = -jump_strength * 0.85
		if anim.flip_h:
			velocity.x = max_speed
		else:
			velocity.x = -max_speed
		
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

func _apply_gravity(delta: float, gravity_scale: float = 1):
	velocity += get_gravity() * delta * gravity_scale
	

func _limit_horizontal_velocity(max_vel: int):
	if velocity.x > 20:
		if velocity.x > max_vel:
			velocity.x = max_vel
	elif velocity.x < -20:
		if velocity.x < -max_vel:
			velocity.x = -max_vel
	else:
		velocity.x = 0

func _reduce_horizontal_velocity(delta: float, amount_per_second: int):
	if velocity.x < -20:
		velocity.x += amount_per_second * delta
	elif velocity.x > 20:
		velocity.x -= amount_per_second * delta


func _die(): #TEMPOARY
	print("player dying")
	dead = true
	GameManager.player_died()
	death_particles.restart()
	anim.play("Die")
	audio_stream.stream = audio_files["die"]
	audio_stream.volume_db = -8
	audio_stream.pitch_scale = randf_range(0.9, 1.1)
	audio_stream.play()

func hit(vec: Vector2):
	velocity = vec * max_speed * 1.5
	_die()

func _update_anim(m):
	if dead:
		return
		
	if m > 0:
		anim.flip_h = false
	if m < 0:
		anim.flip_h = true

	if is_on_floor():
		if m == 0:
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
