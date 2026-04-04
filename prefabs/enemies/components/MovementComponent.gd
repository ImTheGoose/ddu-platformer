extends Node

class_name MovementComponent 

@export_category("Nodes")
@export var entity_root :Entity
@export var health_component :HealthComponent

@export_category("Movement Config")
@export var speed :int = 35
var velocity :float = 0
@export_exp_easing("inout") var accelleration :float = .5
@export_exp_easing("attenuation") var deaccelleration :float = .5


signal target_reached
var target_position :Vector2 = Vector2.ZERO

var movement_blocked :bool = false
var should_move :bool = false

func _ready() -> void:
	entity_root.entity_reset.connect(_on_entity_reset)

func _process(delta: float) -> void:
	if not is_able_to_move():
		return
	
	if not should_move:
		return
	
	var distance_to_target := entity_root.global_position.distance_to(target_position)

	# 1. Calculate our effective deceleration rate (pixels/s^2)
	# Using your logic: speed / deaccelleration
	var braking_rate := float(speed) / deaccelleration

	# 2. Calculate stopping distance: (v^2) / (2 * a)
	var stopping_distance := (velocity * velocity) / (2.0 * braking_rate)

	# 3. Decision: Should we brake or gas it?
	if distance_to_target <= stopping_distance:
		# BRAKE
		velocity -= braking_rate * delta
	else:
		# ACCELERATE
		var accel_rate := float(speed) / accelleration
		velocity += accel_rate * delta 
	# Keep velocity within bounds
	velocity = clamp(velocity, 0, speed)
	
	if is_at_target():
		target_reached.emit()
		return

	_move_towards_position(delta, target_position)
	
func _move_towards_position(delta: float, gpos: Vector2) -> void:
	var dir :Vector2 = entity_root.global_position.direction_to(gpos)
	entity_root.global_position += dir * velocity * delta

func is_at_target() -> bool:	
	var distance :float = entity_root.global_position.distance_to(target_position)
	
	if distance < 1:
		return true
		
	return false
	
func _on_entity_reset() -> void:
	velocity = speed

func set_target(gpos: Vector2) -> void:
	target_position = gpos

func is_able_to_move() -> bool:
	if health_component:
		if health_component.is_dead():
			return false
	
	if movement_blocked:
		return false
	
	return true

func is_moving() -> bool:
	if not is_able_to_move():
		return false
	
	if is_at_target():
		return false
	
	if not should_move:
		return false
	
	return true

func start_moving() -> void:
	should_move = true

func stop_moving() -> void:
	velocity = 0.0
	should_move = false

func block_movement() -> void:
	movement_blocked = true

func resume_movement() -> void:
	movement_blocked = false
