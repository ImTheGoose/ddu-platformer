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
		path_detection_component.valid_path_detected.connect(_on_valid_path_detected)
		path_detection_component.direction_changed.connect(_on_direction_changed)
	
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

func _on_valid_path_detected() -> void:
	_randomise_path()

func _randomise_path() -> void:
	if !multiplayer.is_server():
		return
	
	if !path_detection_component.is_valid_path():
		return
	
	if entity_node.enabled_modifiers.has(Entity.EntityModifiers.BLOCK_RANDOMISE):
		return
	
	var gpos_posi :Vector2 = path_detection_component.point_positive.global_position
	var gpos_nega :Vector2 = path_detection_component.point_negative.global_position
	var gpos :Vector2 = gpos_posi.lerp(gpos_nega, randf())
	movement_component.rpc("set_position", gpos)
	
	var modi :Array[int] = entity_node.enabled_modifiers
	if modi.has(Entity.EntityModifiers.INITIAL_DIRECTION_POSITIVE) or modi.has(Entity.EntityModifiers.INITIAL_DIRECTION_NEGATIVE):
		return
	
	if randf() > 0.5:
		path_detection_component.rpc("set_target", true)
		print("Forced direction positive for %s" % entity_node.name)
	else:
		path_detection_component.rpc("set_target", false)
		print("Forced direction Negative for %s" % entity_node.name)

func _on_direction_changed(new_dir: Vector2) -> void:
	_update_movement_target()

func _update_movement_target() -> void:
	var target_node:Node2D = path_detection_component.get_target()
	if not target_node:
		return
	
	var gpos :Vector2 = target_node.global_position
	var offset :Vector2 = edge_offset * path_detection_component.get_direction()
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
