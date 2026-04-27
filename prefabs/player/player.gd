extends CharacterBody2D

class_name Player 

@export_group("Movement Settings")
@export var jump_strength :int = 400
@export var speed_per_second :int = 1000
@export var max_speed :int = 150
@export var jump_buffer_time :float = 0.1
@export var wall_gravity_scale :float = 0.15
@export var wall_max_velcoity :int = 500

@export_group("Multiplayer Settings")
@export_range(0,100,1.0) var peer_lerp_speed :float = 30
@export_range(0,200, 5) var snap_distance :float = 100

@export_group("Sound Settings")
@export var death_sounds :Dictionary[AudioStream, float] = {preload("uid://dafct6iqadbur") : 0.7}
@export var jump_sounds :Dictionary[AudioStream, float] = {preload("uid://we1luimcp6fb") : 0.2}
@export var footstep_sounds :Dictionary[AudioStream, float] = {preload("uid://cap73awyf8ake") : 0.3}
@export_range(0,0.5) var seconds_between_footsteps :float = 0.1
var seconds_since_footstep :float = 0.0

@onready var dead_enemy_killzone: Area2D = %dead_enemy_killzone
@onready var enemy_killzone: Area2D = %enemy_killzone
@onready var dust_particles :GPUParticles2D = $dust_particles
@onready var jump_particles :GPUParticles2D = $jump_particles
@onready var death_particles :GPUParticles2D = $die_particles
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var feet_position: Node2D = %feet_position

@onready var multi_sync :MultiplayerSynchronizer = $MultiplayerSynchronizer
var sync_position: Vector2 = Vector2.ZERO
var sync_velocity: Vector2 = Vector2.ZERO
var spawn_position :Vector2 = Vector2.ZERO

var reset_ready :bool = true
var dead :bool = false #TEMPOARY
var double_jumped :bool = false
var air_time :float = 0

var assigned_peer_id :int = -1
var assigned_player_info :PlayerInfo

func _enter_tree() -> void:
	if Lobby.is_id_local(assigned_peer_id):
		set_multiplayer_authority(1)
	else:
		set_multiplayer_authority(assigned_peer_id)
	
	assigned_player_info = Lobby.get_player_info(assigned_peer_id)

func _ready() -> void:
	spawn_position = Vector2(0, -500)

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority() or dead:
		return
	
	if event.is_pressed():
		if assigned_player_info.is_jump_event_from_inputs(event):
			_attempt_jump()

func _physics_process(delta: float) -> void:
	if !MenuHandler.is_game_visible():
		return
	
	seconds_since_footstep += delta
	
	set_collision_mask_value(4, GameManager.is_collissions_enabled())
	if !is_multiplayer_authority():
		z_index = 0
		velocity = sync_velocity
		var distance :float = global_position.distance_to(sync_position)
		if distance > snap_distance:
			global_position = sync_position
		else:
			var weight :float = 1 - exp(-peer_lerp_speed * delta)
			global_position = global_position.lerp(sync_position, weight)
		
		if dead:
			return
		
		move_and_slide()
		_update_anim(velocity.x)
		return
	else:
		z_index = 1
		sync_velocity = velocity
		sync_position = global_position
	
	if dead:
		dead_enemy_killzone.monitorable = true
		dead_enemy_killzone.monitoring = true
		dead_enemy_killzone.visible = true
		var col :CollisionShape2D = $CollisionShape2D
		col.disabled = true
		_limit_horizontal_velocity(max_speed * 4)
		_reduce_horizontal_velocity(delta, speed_per_second / 20.0)
		_apply_gravity(delta, 0.65)
		move_and_slide()
		return
	
	var height_reached :float = Stats.get_recording_value(Stats.StatType.HEIGHT_REACHED)
	var height :float = (spawn_position.y - global_position.y) / 16
	if height > height_reached:
		Stats.set_recording_value(Stats.StatType.HEIGHT_REACHED, height)
	
	dead_enemy_killzone.monitorable = false
	dead_enemy_killzone.monitoring = false
	dead_enemy_killzone.visible = false
	
	var move_axis :float = assigned_player_info.get_movement_axis()
	_limit_horizontal_velocity(max_speed)
	if move_axis == 0:
		_reduce_horizontal_velocity(delta, speed_per_second)
	
	if is_on_floor() or is_on_wall():
		double_jumped = false
		air_time = 0
	else:
		air_time += delta

	velocity.x += move_axis * speed_per_second * delta

	if is_on_wall_only() && velocity.y > 0:
		_apply_gravity(delta, wall_gravity_scale)
		if velocity.y > wall_max_velcoity:
			velocity.y = wall_max_velcoity
		
	else:
		_apply_gravity(delta)

	if is_on_floor() or velocity.y < -20:
		enemy_killzone.monitorable = false
		enemy_killzone.monitoring = false
		enemy_killzone.visible = false
	else:	
		enemy_killzone.monitorable = true
		enemy_killzone.monitoring = true
		enemy_killzone.visible = true
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
		Stats.add_recording_value(Stats.StatType.JUMPS_WALL, 1)
		rpc("show_jump")
	
	elif is_on_floor() or air_time < jump_buffer_time:
		air_time = jump_buffer_time
		velocity.y = -jump_strength
		Stats.add_recording_value(Stats.StatType.JUMPS_GROUND, 1)
		rpc("show_jump")

	elif !double_jumped:
		double_jumped = true
		velocity.y = -jump_strength * 0.85
		Stats.add_recording_value(Stats.StatType.JUMPS_DOUBLE, 1)
		rpc("show_jump", true)

@rpc("authority","call_local","reliable")
func show_jump(isDoubleJump: bool = false) -> void:
	if isDoubleJump:
		anim.play("Double_Jump")
	else:
		anim.play("Jump")
		
	jump_particles.restart(false)
	Audio.play_random_pitched(jump_sounds)
	return

func _apply_gravity(delta: float, gravity_scale: float = 1) -> void:
	velocity += get_gravity() * delta * gravity_scale

func _limit_horizontal_velocity(max_vel: int) -> void:
	if velocity.x > 5:
		if velocity.x > max_vel:
			velocity.x = max_vel
	elif velocity.x < -5:
		if velocity.x < -max_vel:
			velocity.x = -max_vel
	else:
		velocity.x = 0

func _reduce_horizontal_velocity(delta: float, amount_per_second: float) -> void:
	if velocity.x < -5:
		velocity.x += amount_per_second * delta
		if velocity.x > 0:
			velocity.x = 0
	elif velocity.x > 5:
		velocity.x -= amount_per_second * delta
		if velocity.x < 0:
			velocity.x = 0
	else:
		velocity.x = 0

@rpc("any_peer", "call_local","reliable")
func reset_player(gpos:Vector2) -> void:
	var col :CollisionShape2D = $CollisionShape2D
	col.disabled = false
	velocity = Vector2.ZERO
	global_position = gpos
	spawn_position = Vector2(0, -500)
	Stats.set_recording_value(Stats.StatType.HEIGHT_REACHED, 0.0)
	rpc("show_reset")
	reset_ready = true

@rpc("authority","call_local","reliable")
func show_reset() -> void:
	set_collision_mask_value(5, GameManager.is_collissions_enabled())
	dead = false
	anim.play("Idle")
	death_particles.restart()
	death_particles.emitting = false
	dust_particles.restart()
	rotation = 0

func _die() -> void: #TEMPOARY
	reset_ready = false
	GameManager.rpc("player_died", assigned_peer_id, GameManager.round_seconds_passed)
	rpc("show_death")

@rpc("authority","call_local","reliable")
func show_death() -> void:
	dead = true
	death_particles.restart()
	anim.play("Die")
	Audio.play_random_pitched(death_sounds)

func hit(vec: Vector2) -> void:
	if is_multiplayer_authority() && !dead && GameManager.is_game_running():
		knockback(vec, max_speed * 1.5)
		GameManager.add_camera_shake.emit(1.8, -vec, 15)
		_die()

func knockback(dir: Vector2, power: float, reset_jump: bool = false) -> void:
	if reset_jump:
		double_jumped = false
	
	velocity = dir * power
	return

func get_feet_node() -> Node2D:
	return feet_position

func _update_anim(move_axis: float) -> void:
	if dead:
		return

	if is_on_floor():
		if move_axis == 0:
			anim.play("Idle")
			dust_particles.emitting = false
		else:
			anim.play("Run")
			dust_particles.emitting = true
			if seconds_since_footstep >= seconds_between_footsteps:
				seconds_since_footstep = 0.0
				Audio.play_random(footstep_sounds, 0.9)

	elif !is_on_wall_only():
		if velocity.y < 0 && !double_jumped:
			dust_particles.emitting = false
			anim.play("Jump")
		elif anim.animation != "Double_Jump" && velocity.y < 0 && double_jumped:
			anim.play("Double_Jump")

		if velocity.y > 0:
			if anim.is_playing() && anim.animation == "Double_Jump":
				return
			anim.play("Fall")
			dust_particles.emitting = false
	elif is_on_wall_only() && velocity.y > 0:
		anim.play("Wall_Jump")
