extends CharacterBody2D

class_name Player

@export var jump_strength :int = 1250
@export var accelleration_per_second :int = 3000
@export var max_speed :int = 450
@export var jump_buffer_time :float = 0.1
@export var wall_gravity_scale :float = 0.15

@onready var collission_shape_2d :CollisionShape2D = %CollisionShape2D

var double_jumped :bool = false
var air_time :float = 0

const INPUT_MAP :Dictionary[String, String] = { ## Skal ændres til globalt inputmap
	"move_left" : "move_left",
	"move_right" : "move_right",
	"jump_action" : "jump"
}

var state :PlayerState = PlayerState.IDLE

enum PlayerState {
	IDLE,
	RUNNING,
	ON_WALL,
	IN_AIR,
	DEAD,
}

func _physics_process(delta: float) -> void:
	if state == PlayerState.DEAD:
		_handle_dead_player(delta)
	else:
		_handle_alive_player(delta)
	move_and_slide()
	print(state)

func _handle_dead_player(delta: float) -> void:
	velocity.x = clamp(velocity.x, -max_speed * 4, max_speed * 4)
	velocity += get_gravity() * delta * 0.65
	collission_shape_2d.disabled = true
	_reduce_horizontal_velocity(delta, accelleration_per_second / 20)

func _handle_alive_player(delta: float) -> void:
	var move_axis :float = Input.get_axis(INPUT_MAP["move_left"], INPUT_MAP["move_right"])
	
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.x += move_axis * accelleration_per_second * delta
	
	
	if move_axis == 0:
		_reduce_horizontal_velocity(delta, accelleration_per_second)
	
	if is_on_floor():
		if move_axis == 0:
			state = PlayerState.IDLE
		else:
			state = PlayerState.RUNNING
	
	elif is_on_wall():
		state = PlayerState.ON_WALL
		
	else:
		state = PlayerState.IN_AIR
	
	if is_player_grounded():
		double_jumped = false
		air_time = 0
	else:
		air_time += delta

	if Input.is_action_just_pressed(INPUT_MAP["jump_action"]):
		_handle_jump()
	
	if state == PlayerState.ON_WALL && velocity.y > 0:
		velocity += get_gravity() * delta * wall_gravity_scale
	else:
		velocity += get_gravity() * delta * 1

func _reduce_horizontal_velocity(delta: float, amount_per_second: float) -> void:
	if velocity.x < -20:
		velocity.x += amount_per_second * delta
	elif velocity.x > 20:
		velocity.x -= amount_per_second * delta
	else:
		velocity.x = 0

func is_player_grounded() -> bool:
	return state == PlayerState.ON_WALL or state == PlayerState.IDLE or state == PlayerState.RUNNING

func hit(vec: Vector2) -> void:
	velocity = vec * max_speed * 1.5
	#_die()

func _handle_jump() -> void:
	if state == PlayerState.ON_WALL:
		velocity.y = -jump_strength * 0.85
		if get_wall_normal().normalized().x > 0:
			velocity.x = max_speed
		else:
			velocity.x = -max_speed
		
		air_time = jump_buffer_time
		StatisticManager.add_value("wall_jump", 1)
		return
	
	if state == PlayerState.IDLE or state == PlayerState.RUNNING or air_time < jump_buffer_time:
		air_time = jump_buffer_time
		velocity.y = -jump_strength
		StatisticManager.add_value("ground_jump", 1)
		return
	
	if !double_jumped:
		double_jumped = true
		velocity.y = -jump_strength * 0.85
		StatisticManager.add_value("double_jump", 1)
	
