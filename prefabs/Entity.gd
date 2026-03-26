extends Node2D

class_name Entity 

@export var entity_type :EntitySpawner.SpawnType
@onready var initial_process_mode :ProcessMode = process_mode
signal enabled
signal disabled
signal entity_reset


@rpc("authority","call_local","reliable")
func disable() -> void:
	global_position.x += 2000
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	_on_disable()
	return

func _on_disable() -> void:
	return

@rpc("authority","call_local","reliable")
func enable(new_gpos: Vector2 = Vector2.ZERO) -> void:
	reset()
	visible = true
	process_mode = initial_process_mode
	if new_gpos != Vector2.ZERO:
		global_position = new_gpos
	
	_on_enable()
	return

func _on_enable() -> void:
	return

func reset() -> void:
	_on_reset()
	entity_reset.emit()

func _on_reset() -> void:
	return
