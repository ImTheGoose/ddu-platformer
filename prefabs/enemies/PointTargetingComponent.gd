extends Node

class_name PointTargetingComponent 

@export var entity_node :Entity
@export var path_detection_component :PathDetectionComponent
@export var movement_component :MovementComponent

@export_category("Movement Config")
@export_range(-8,8,1.0) var edge_offset = 0.0
@export_range(0,5, 0.1) var seconds_waiting_at_target :float = 2.0
var seconds_waited :float = 0.0

func _ready() -> void:
	if movement_component:
		movement_component.target_reached.connect(_on_target_reached)
	
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)
	
	if path_detection_component:
		path_detection_component.valid_path_detected.connect(_update_movement_target)
	
	_update_movement_target()
	movement_component.start_moving()

func _process(delta: float) -> void:
	if not path_detection_component.is_valid_path():
		movement_component.block_movement()
		return
	else:
		movement_component.resume_movement()
	
	if movement_component.is_at_target():
		seconds_waited += delta
	
	if seconds_waited > seconds_waiting_at_target:
		seconds_waited = 0.0
		path_detection_component.swap_target()
		_update_movement_target()
		movement_component.start_moving()

func _update_movement_target() -> void:
	var target_node:Node2D = path_detection_component.get_target()
	if not target_node:
		return
	
	var gpos :Vector2 = target_node.global_position
	var offset :Vector2 = edge_offset * entity_node.global_scale * path_detection_component.get_direction()
	movement_component.set_target(gpos + offset)

func _on_entity_reset() -> void:
	seconds_waited = 0.0
	movement_component.set_target(Vector2.ZERO)
	_update_movement_target()
	movement_component.start_moving()

func _on_target_reached() -> void:
	movement_component.stop_moving()
	seconds_waited = 0.0
	return
