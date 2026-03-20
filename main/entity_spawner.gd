extends MultiplayerSpawner

@export var entity_prefabs :Dictionary[int, PackedScene] = {
	EntitySpawn.SpawnType.ENEMY_MUSHROOM: preload("uid://bm73fykqwqf6j"),
	EntitySpawn.SpawnType.ENEMY_TRUNK: preload("uid://cl3ty1bxj7fwe"),
	EntitySpawn.SpawnType.TRAP_FIRE_PLATE: preload("uid://cocuafbfox40i"),
	EntitySpawn.SpawnType.TRAP_FALLING_PLATFORM: preload("uid://cc8s1kq0yww6p"),
	EntitySpawn.SpawnType.TRAP_TRAMPOLINE: preload("uid://cq0dyrn14nfnf"),
	EntitySpawn.SpawnType.TRAP_POWER_TRAMPOLINE: preload("uid://bh3pdvlpgdufq"),
	EntitySpawn.SpawnType.COLLECTABLE_APPLE: preload("uid://btu7xbmgfkame"),
}

func _ready() -> void:
	spawn_function = _spawn_entity
	GameManager.spawn_entity.connect(_on_spawn_entity)
	GameManager.server_reset.connect(_on_server_reset)

func _on_spawn_entity(gpos: Vector2, spawn_type: int) -> void:
	if !multiplayer.is_server():
		return

	var spawn_rate :float = _get_spawnrate(spawn_type)
	var rand_float :float = randf()
	if rand_float > spawn_rate:
		return
	
	spawn([gpos, spawn_type, randf(), randf()])


func _get_spawnrate(spawn_type: int) -> float:
	match spawn_type:
		EntitySpawn.SpawnType.ENEMY_MUSHROOM, EntitySpawn.SpawnType.ENEMY_TRUNK:
			return min(GameManager.get_difficulty_value("enemy_spawn_rate"), 1.0)
		EntitySpawn.SpawnType.COLLECTABLE_APPLE:
			return min(GameManager.get_difficulty_value("collectable_spawn_rate"), 1.0)
	
	return 1.0


func _on_server_reset() -> void:
	if !multiplayer.is_server() && multiplayer.get_peers().size() != 0:
		return
		
	var entity_container :Node2D = get_node(spawn_path)
	for child in entity_container.get_children():
		child.queue_free()
	

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
