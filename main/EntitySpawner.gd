extends MultiplayerSpawner

class_name EntitySpawner 

@export var local_spawn_node :Node2D
@export var spawn_node :Node2D

@export var local_types :Array[SpawnType] = [
	SpawnType.ENEMY_PATHFINDING_POINT,
	SpawnType.TRAP_SPIKE,
	SpawnType.TRAP_SPIKE_LEFT,
	SpawnType.TRAP_SPIKE_RIGHT,
	SpawnType.TRAP_SPIKE_DOWN,
]
@export var entity_prefabs :Dictionary[SpawnType, PackedScene] = {
	SpawnType.ENEMY_PATHFINDING_POINT : preload("uid://dvuu00ynhqps7"),
	SpawnType.ENEMY_MUSHROOM: preload("uid://bm73fykqwqf6j"),
	SpawnType.ENEMY_TRUNK: preload("uid://cl3ty1bxj7fwe"),
	SpawnType.TRAP_SPIKE : preload("uid://dwyc1xb3bavyv"),
	SpawnType.TRAP_SPIKE_DOWN : preload("uid://cnh6641embbwk"),
	SpawnType.TRAP_SPIKE_LEFT : preload("uid://b21toqgef4rn1"),
	SpawnType.TRAP_SPIKE_RIGHT : preload("uid://bnicsngp8cud0"),
	SpawnType.TRAP_FIRE_PLATE: preload("uid://cocuafbfox40i"),
	SpawnType.TRAP_FALLING_PLATFORM: preload("uid://cc8s1kq0yww6p"),
	SpawnType.TRAP_TRAMPOLINE: preload("uid://cq0dyrn14nfnf"),
	SpawnType.TRAP_POWER_TRAMPOLINE: preload("uid://bh3pdvlpgdufq"),
	SpawnType.COLLECTABLE_APPLE: preload("uid://btu7xbmgfkame"),
}

enum SpawnType {
	ENEMY_PATHFINDING_POINT,
	ENEMY_MUSHROOM,
	ENEMY_TRUNK,
	TRAP_SPIKE,
	TRAP_SPIKE_LEFT,
	TRAP_SPIKE_RIGHT,
	TRAP_SPIKE_DOWN,
	TRAP_FIRE_PLATE,
	TRAP_FALLING_PLATFORM,
	TRAP_TRAMPOLINE,
	TRAP_POWER_TRAMPOLINE,
	COLLECTABLE_APPLE,
}

func is_local(type: SpawnType) -> bool:
	return local_types.has(type)

func _ready() -> void:
	spawn_function = _spawn_entity
	GameManager.spawn_entity.connect(_on_spawn_entity)
	GameManager.server_reset.connect(_on_server_reset)
	GameManager.client_reset.connect(_on_client_reset)

func _on_spawn_entity(gpos: Vector2, spawn_type: int) -> void:
	if is_local(spawn_type):
		_spawn_local_entity(gpos, spawn_type)
		return
	
	if !multiplayer.is_server():
		return

	var spawn_rate :float = _get_spawnrate(spawn_type)
	var rand_float :float = randf()
	if rand_float > spawn_rate:
		return
	
	spawn([gpos, spawn_type, randf(), randf()])


func _get_spawnrate(spawn_type: int) -> float:
	match spawn_type:
		SpawnType.ENEMY_MUSHROOM, SpawnType.ENEMY_TRUNK:
			return min(GameManager.get_difficulty_value("enemy_spawn_rate"), 1.0)
		SpawnType.COLLECTABLE_APPLE:
			return min(GameManager.get_difficulty_value("collectable_spawn_rate"), 1.0)
	
	return 1.0


func _on_client_reset() -> void:
	for local_child in local_spawn_node.get_children():
		local_child.queue_free()

func _on_server_reset() -> void:
	if !multiplayer.is_server() && multiplayer.get_peers().size() != 0:
		return
		
	for child in spawn_node.get_children():
		child.queue_free()
	

func _spawn_local_entity(gpos: Vector2, spawn_type: int) -> void:
	if !entity_prefabs.has(spawn_type):
		printerr("No entity prefab for entity with type : %s" % spawn_type)
	
	var e :Node2D = entity_prefabs[spawn_type].instantiate()
	
	local_spawn_node.add_child(e)
	e.global_position = gpos
	
	return

func _spawn_entity(data: Array) -> Node:
	if !entity_prefabs.has(data[1]):
		printerr("No entity prefab for entity with type : %s" % data[1])
		return entity_prefabs[0].instantiate()
	
	var e :Node2D = entity_prefabs[data[1]].instantiate()
	
	e.tree_entered.connect(
		func() -> void:
			e.global_position = data[0]
			
			if e is PathfindingEnemy:
				e.random_floats.append_array([data[2], data[3]])
			)
	
	return e
