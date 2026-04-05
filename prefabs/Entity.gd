extends Node2D

class_name Entity 

@export var entity_type :EntitySpawner.SpawnType
@export var block_rotation :bool = false
@onready var initial_process_mode :ProcessMode = process_mode
var is_disabled :bool = false
signal enabled
signal disabled
signal entity_reset

var enabled_modifiers :Array[int] = []

enum EntityModifiers {
	ROTATE_90,
	ROTATE_180,
	ROTATE_270,
	INITIAL_DIRECTION_POSITIVE,
	INITIAL_DIRECTION_NEGATIVE,
	BLOCK_RANDOMISE,
}

@rpc("authority","call_local","reliable")
func disable() -> void:
	is_disabled = true
	global_position.x += 2000
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	_on_disable()
	enabled_modifiers.clear()
	return

func _on_disable() -> void:
	return

@rpc("authority","call_local","reliable")
func enable(new_gpos: Vector2 = Vector2.ZERO, modifiers: Array[int] = []) -> void:
	enabled_modifiers = modifiers
	is_disabled = false
	visible = true
	process_mode = initial_process_mode
	if new_gpos != Vector2.ZERO:
		global_position = new_gpos
		
	global_rotation_degrees = 0
	if not block_rotation:
		if modifiers.has(EntityModifiers.ROTATE_90):
			global_rotation_degrees = 90
		elif modifiers.has(EntityModifiers.ROTATE_180):
			global_rotation_degrees = 180
		elif modifiers.has(EntityModifiers.ROTATE_270):
			global_rotation_degrees = 270
	
	reset()
	enabled.emit()
	_on_enable()
	return

func _on_enable() -> void:
	return

func reset() -> void:
	_on_reset()
	entity_reset.emit()

func _on_reset() -> void:
	return
