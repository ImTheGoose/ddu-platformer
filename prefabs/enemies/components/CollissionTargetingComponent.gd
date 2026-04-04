extends RayCast2D

class_name CollissionTargetingComponent 

@export var entity_node :Entity
@export var player_detection_component :PlayerDetectionComponent
@export var movement_component :MovementComponent
@export var detection_range :int = 500
@export_range(1,15,0.1) var fall_speed_multiplier :float = 6.0
var original_speed :int = 0
var original_deaccelleration :float = 0.0

@export_category("Movement Config")
@export_range(0,5, 0.1) var seconds_waiting_at_target :float = 2.0
var seconds_waited :float = 0.0

var origin_position :Vector2 = global_position
var moving_towards_collission :bool = false

func _ready() -> void:
	if movement_component:
		movement_component.target_reached.connect(_on_target_reached)
		original_speed = movement_component.speed
		original_deaccelleration = movement_component.deaccelleration
	
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)
	
	target_position = target_position.normalized() * detection_range
	origin_position = entity_node.global_position
	_update_movement_target()
	movement_component.start_moving()

func _process(delta: float) -> void:
	if not is_colliding():
		movement_component.block_movement()
		return
	else:
		movement_component.resume_movement()
	
	if player_detection_component.is_detecting_player():
		_update_movement_target()
		moving_towards_collission = true
		movement_component.start_moving()
	
	if movement_component.is_at_target():
		seconds_waited += delta
	
	if seconds_waited > seconds_waiting_at_target:
		moving_towards_collission = false
		seconds_waited = 0.0
		_update_movement_target()
		movement_component.start_moving()

func _update_movement_target() -> void:
	if not moving_towards_collission:
		movement_component.set_target(origin_position)
		movement_component.speed = original_speed
		movement_component.deaccelleration = movement_component.accelleration
		return
	
	if not is_colliding():
		return
	
	movement_component.deaccelleration = original_deaccelleration
	movement_component.speed = original_speed * fall_speed_multiplier
	var gpos :Vector2 = get_collision_point()
	movement_component.set_target(gpos)

func _on_entity_reset() -> void:
	origin_position = entity_node.global_position
	moving_towards_collission = false
	seconds_waited = 0.0
	movement_component.set_target(Vector2.ZERO)
	_update_movement_target()
	movement_component.start_moving()

func _on_target_reached() -> void:
	movement_component.stop_moving()
	seconds_waited = 0.0
	return
