extends Node

class_name MovementComponent 

@export_category("Nodes")
@export var entity_root :Entity
@export var path_detection_component :PathDetectionComponent
@export var health_component :HealthComponent

@export_category("Movement Config")
@export var speed :int = 100
@export_range(-8,8,1.0) var edge_offset = 0.0
@export_range(0,5, 0.1) var seconds_waiting_at_target :float = 2.0
var seconds_waited :float = 0.0


signal target_reached

var movement_blocked :bool = false

func _ready() -> void:
	if not path_detection_component:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	if not entity_root:
		process_mode = Node.PROCESS_MODE_DISABLED
		return

func _process(delta: float) -> void:
	if not is_able_to_move():
		return
	
	if is_at_target():
		if seconds_waited == 0.0:
			target_reached.emit()
		seconds_waited += delta
		if seconds_waited > seconds_waiting_at_target:
			seconds_waited = 0.0
			path_detection_component.swap_target()
	
	var target :Node2D = path_detection_component.get_target()
	var offset :Vector2 = entity_root.global_scale * path_detection_component.get_direction() * edge_offset
	var gpos :Vector2 = target.global_position + offset

	_move_towards_position(delta, gpos)
	
func _move_towards_position(delta: float, gpos: Vector2) -> void:
	var dir :Vector2 = entity_root.global_position.direction_to(gpos)
	entity_root.global_position += dir * speed * delta

func is_at_target() -> bool:
	var target :Node2D = path_detection_component.get_target()
	if not target:
		return false
	
	var offset :Vector2 = entity_root.global_scale * path_detection_component.get_direction() * edge_offset
	var gpos :Vector2 = target.global_position + offset
	var distance :float = entity_root.global_position.distance_to(gpos)
	
	if distance < 1:
		return true
		
	return false

func is_able_to_move() -> bool:
	if health_component.is_dead():
		return false
	
	if not path_detection_component.is_valid_path():
		return false
	
	if movement_blocked:
		return false
	
	return true

func is_moving() -> bool:
	if not is_able_to_move():
		return false
	
	if is_at_target():
		return false
	
	return true

func block_movement() -> void:
	movement_blocked = true

func resume_movement() -> void:
	movement_blocked = false
