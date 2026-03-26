extends MultiplayerSpawner

class_name EntitySpawner 

@export var bottom_safe_distance :int = 1600
@export var seconds_between_clear :int = 5
var seconds_since_clear :float = 0
@export var map_gen_node :Node2D
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
var spawned_entities :Dictionary[SpawnType, Array]
var unused_entities :Dictionary[SpawnType, Array] = {}


#region Local Spawning
func is_local(type: SpawnType) -> bool:
	return local_types.has(type)

func _on_client_reset() -> void:
	unused_entities.clear()
	spawned_entities.clear()
	for local_child in local_spawn_node.get_children():
		local_child.queue_free()

func _spawn_local_entity(gpos: Vector2, spawn_type: int) -> void:
	if !entity_prefabs.has(spawn_type):
		printerr("No entity prefab for entity with type : %s" % spawn_type)
	
	if unused_entities.has(spawn_type):
		if unused_entities[spawn_type].size() > 0:
			var node: Entity = unused_entities[spawn_type].pop_back()
			node.rpc("enable", gpos)
			print("Reusing an existing local asset")
			return
	
	var e :Node2D = entity_prefabs[spawn_type].instantiate()
	
	local_spawn_node.add_child(e)
	e.global_position = gpos
	
	if !spawned_entities.has(spawn_type):
		spawned_entities.set(spawn_type, [])

	spawned_entities[spawn_type].append(e)
	
	return

#endregion

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	spawn_function = _spawn_entity
	GameManager.spawn_entity.connect(_on_spawn_entity)
	GameManager.server_reset.connect(_on_server_reset)
	GameManager.client_reset.connect(_on_client_reset)
	GameManager.spawn_level.connect(_on_spawn_level)
	Performance.add_custom_monitor("game/enemies", get_entity_count)

func get_entity_count() -> int:
	var total_entites :int = 0
	for arr:Array in spawned_entities.values():
		total_entites += arr.size()
	return total_entites

func _process(delta: float) -> void:
	if seconds_since_clear < seconds_between_clear:
		seconds_since_clear += delta
	else:
		seconds_since_clear = 0.0
		clear_unused_children()

func _get_spawnrate(spawn_type: int) -> float:
	match spawn_type:
		SpawnType.ENEMY_MUSHROOM, SpawnType.ENEMY_TRUNK:
			return min(GameManager.get_difficulty_value("enemy_spawn_rate"), 1.0)
		SpawnType.COLLECTABLE_APPLE:
			return min(GameManager.get_difficulty_value("collectable_spawn_rate"), 1.0)
	
	return 1.0


#region Server Spawning
func _on_server_reset() -> void:
	if !multiplayer.is_server():
		return
		
	for child in spawn_node.get_children():
		child.queue_free()

	for child in map_gen_node.get_children():
		child.queue_free()

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
	
	if unused_entities.has(spawn_type):
		if unused_entities[spawn_type].size() > 0:
			var node: Entity = unused_entities[spawn_type].pop_back()
			node.rpc("enable", gpos)
			print("Reusing an existing node")
			return
	
	var node :Node = spawn([gpos, spawn_type, randf(), randf()])
	
	if !spawned_entities.has(spawn_type):
		spawned_entities.set(spawn_type, [])

	spawned_entities[spawn_type].append(node)

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

#endregion


func get_spawn_amount(type: SpawnType) -> int:
	match type:
		SpawnType.ENEMY_MUSHROOM, SpawnType.ENEMY_TRUNK:
			return 15
		SpawnType.COLLECTABLE_APPLE:
			return 100
		_:
			return 30

func _on_spawn_level() -> void:
	for type in entity_prefabs.keys():
		if !is_local(type) && !multiplayer.is_server():
			continue
		for i:int in range(get_spawn_amount(type)):
			_on_spawn_entity(Vector2(-1, -1), type)
	
	seconds_since_clear = seconds_between_clear - 0.05
	
	return

#region Entity & Map Pruning
func clear_unused_children() -> void:
	if !MenuHandler.is_game_visible():
		return
	
	var players :Array[Node] = get_tree().get_nodes_in_group("Players")
	if players.is_empty():
		return
	
	var highest_player :Player = players[0]
	var lowest_player :Player = players[0]
	for p:Player in players:
		if p.dead:
			continue
		
		if p.global_position.y < highest_player.global_position.y:
			highest_player = p
		
		if p.global_position.y > lowest_player.global_position.y:
			lowest_player = p
	
	print("clearing objects")
	var cleared :int = 0
	var disabled :int = 0
	
	var local_children :Array[Node] = local_spawn_node.get_children()
	for child: Node in local_children:
		if child is Entity:
			if child.global_position.y > lowest_player.global_position.y + bottom_safe_distance or child.global_position == Vector2(-1, -1):
				disabled += 1
				child.disable()
				add_node_to_unused(child)
	
	if !multiplayer.is_server():
		return
	
	var children :Array[Node] = spawn_node.get_children()
	children.append_array(map_gen_node.get_children())
	
	for child: Node in children:
		if child is not Node2D or players.has(child):
			return
		
		if child.global_position.y > lowest_player.global_position.y + bottom_safe_distance or child.global_position == Vector2(-1, -1):
			if child is Entity:
				disabled += 1
				child.rpc("disable")
				add_node_to_unused(child)
			else:
				cleared += 1
				child.queue_free()
	print("Cleared a total of %s objects" % cleared)
	print("Disabled a total of %s objects" % disabled)

func add_node_to_unused(node: Entity) -> void:
	var type :SpawnType = node.entity_type
	if !unused_entities.has(type):
		unused_entities.set(type, [])
	
	unused_entities[type].append(node)

#endregion
