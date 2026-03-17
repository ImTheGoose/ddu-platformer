extends Node2D

class_name EntitySpawn 

@export var type :SpawnType = SpawnType.ENEMY_MUSHROOM

func _ready() -> void:
	if multiplayer.is_server():
		GameManager.spawn_entity.emit(global_position, type)
	queue_free()

enum SpawnType {
	ENEMY_MUSHROOM,
	ENEMY_TRUNK,
	TRAP_FIRE_PLATE,
	TRAP_FALLING_PLATFORM,
	TRAP_TRAMPOLINE,
	TRAP_POWER_TRAMPOLINE,
	COLLECTABLE_APPLE,
}
