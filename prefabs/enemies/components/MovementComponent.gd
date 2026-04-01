extends Node

class_name MovementComponent 

@export_category("Nodes")
@export var entity_root :Entity
@export var path_detection_component :PathDetectionComponent
@export var health_component :HealthComponent

@export_category("Movement Config")
@export var speed :int = 100
@export_range(0,5, 0.1) var seconds_waiting_at_target :float = 2.0
var seconds_waited :float = 0.0

signal movement_state_changed
var state :MovementState = MovementState.WAITING:
	set(value):
		if state != value:
			state = value
			movement_state_changed.emit()

enum MovementState {
	WAITING,
	MOVING,
}

func _ready() -> void:
	if not path_detection_component:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	if not entity_root:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	entity_root.entity_reset.connect(_on_entity_reset)

func _process(delta: float) -> void:
	if health_component:
		if health_component.is_dead():
			return
	
	if not path_detection_component.is_valid_path():
		return
	
	var target :Node2D = path_detection_component.get_target()
	var gpos :Vector2 = target.global_position
	var distance :float = entity_root.global_position.distance_to(gpos)
	
	if distance < 1:
		if seconds_waited < seconds_waiting_at_target:
			state = MovementState.WAITING
			seconds_waited += delta
			return
		else:
			seconds_waited = 0.0
			path_detection_component.swap_target()

	state = MovementState.MOVING
	
	_move_towards_position(delta, gpos)
	
func _move_towards_position(delta: float, gpos: Vector2) -> void:
	var dir :Vector2 = entity_root.global_position.direction_to(gpos)
	entity_root.global_position += dir * speed * delta

func _on_entity_reset() -> void:
	seconds_waited = 0
	return

func stop_moving() -> void:
	return

func start_moving() -> void:
	return

func is_waiting() -> bool:
	return state == MovementState.WAITING
