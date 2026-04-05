extends MultiplayerSpawner

class_name EntitySpawner 

@export var bottom_safe_distance :int = 300
@export var seconds_between_clear :int = 5
var seconds_since_clear :float = 0
@export var map_gen_node :Node2D
@export var local_spawn_node :Node2D
@export var spawn_node :Node2D

@export var local_types :Array[SpawnType] = [
	SpawnType.ENEMY_PATHFINDING_POINT,
	SpawnType.TRAP_PATHFINDING_POINT,
	SpawnType.BIG_ENEMY_PATHFINDING_POINT,
	SpawnType.ENEMY_MOVING_HEAD,
	SpawnType.ENEMY_SPIKED_MOVING_HEAD,
	SpawnType.TRAP_SPIKE,
	SpawnType.TRAP_FANS,
]
@export var entity_prefabs :Dictionary[SpawnType, PackedScene] = {
	SpawnType.ENEMY_PATHFINDING_POINT : preload("uid://dvuu00ynhqps7"),
	SpawnType.TRAP_PATHFINDING_POINT : preload("uid://b5jetmt6yygr8"),
	SpawnType.ENEMY_MUSHROOM: preload("uid://cotlp2mae8vp7"),
	SpawnType.ENEMY_TRUNK: preload("uid://daa708mlqvqkn"),
	SpawnType.ENEMY_PLANT: preload("uid://c1mt2bnj7pmli"),
	SpawnType.ENEMY_BIRD : preload("uid://c011nvwhwv1ii"),
	SpawnType.ENEMY_GHOST : preload("uid://bihwcphf4kctd"),
	SpawnType.ENEMY_ROCKS_BIG : preload("uid://do5gbabi2agsb"),
	SpawnType.ENEMY_ROCKS_MEDIUM : preload("uid://72kyayuiloib"),
	SpawnType.ENEMY_ROCKS_SMALL : preload("uid://b14td6vruqott"),
	SpawnType.ENEMY_FAT_BIRD : preload("uid://bbtr8h0akbyoy"),
	SpawnType.TRAP_SPIKE : preload("uid://dwyc1xb3bavyv"),
	SpawnType.TRAP_FIRE_PLATE: preload("uid://cocuafbfox40i"),
	SpawnType.TRAP_FALLING_PLATFORM: preload("uid://cc8s1kq0yww6p"),
	SpawnType.TRAP_TRAMPOLINE: preload("uid://cq0dyrn14nfnf"),
	SpawnType.TRAP_POWER_TRAMPOLINE: preload("uid://bh3pdvlpgdufq"),
	SpawnType.TRAP_FANS: preload("uid://clkaqpool53jm"),
	SpawnType.COLLECTABLE_APPLE: preload("uid://btu7xbmgfkame"),
	SpawnType.BIG_ENEMY_PATHFINDING_POINT : preload("uid://cguvqe11b0yep"),
	SpawnType.ENEMY_MOVING_HEAD : preload("uid://coh68rs8aoqfu"),
	SpawnType.ENEMY_SPIKED_MOVING_HEAD : preload("uid://driakspag286k"),
}

enum SpawnType {
	ENEMY_PATHFINDING_POINT,
	ENEMY_MUSHROOM,
	ENEMY_TRUNK,
	ENEMY_PLANT,
	ENEMY_BIRD,
	ENEMY_FAT_BIRD,
	ENEMY_GHOST,
	ENEMY_ROCKS_BIG,
	ENEMY_ROCKS_MEDIUM,
	ENEMY_ROCKS_SMALL,
	TRAP_SPIKE,
	TRAP_FIRE_PLATE,
	TRAP_FALLING_PLATFORM,
	TRAP_TRAMPOLINE,
	TRAP_POWER_TRAMPOLINE,
	TRAP_FANS,
	ENEMY_MOVING_HEAD,
	ENEMY_SPIKED_MOVING_HEAD,
	TRAP_PATHFINDING_POINT,
	COLLECTABLE_APPLE,
	BIG_ENEMY_PATHFINDING_POINT,
}
var spawned_entities :Dictionary[SpawnType, Array] = {}
var unused_entities :Dictionary[SpawnType, Array] = {}


#region Local Spawning
func is_local(type: SpawnType) -> bool:
	return local_types.has(type)

func _on_client_reset() -> void:	
	for key in unused_entities.keys():
		if is_local(key):
			unused_entities.set(key, [])
	
	for child in local_spawn_node.get_children():
		if child is Entity:
			child.disable()
			add_node_to_unused(child)

func _spawn_local_entity(gpos: Vector2, spawn_type: int, modifiers: Array[int]) -> void:
	if !entity_prefabs.has(spawn_type):
		printerr("No entity prefab for entity with type : %s" % spawn_type)
	
	if unused_entities.has(spawn_type) && gpos != Vector2(-1, -1):
		if unused_entities[spawn_type].size() > 0:
			var node: Entity = unused_entities[spawn_type].pop_back()
			node.enable(gpos, modifiers)
			return
	
	var e :Entity = entity_prefabs[spawn_type].instantiate()
	local_spawn_node.add_child(e)
	
	if gpos == Vector2(-1, -1):
		if e is Entity:
			e.disable()
			add_node_to_unused(e)
	else:
		e.enable(gpos, modifiers)
	
	add_node_to_spawned(e)

#endregion


#region Server Spawning
func _on_server_reset() -> void:
	if !multiplayer.is_server():
		return
	
	for key in unused_entities.keys():
		if !is_local(key):
			unused_entities.set(key, [])
	
	for child in spawn_node.get_children():
		if child is Entity:
			child.rpc("disable")
			add_node_to_unused(child)
			
	for child in map_gen_node.get_children():
		child.queue_free()

func _on_spawn_entity(gpos: Vector2, spawn_type: int, modifiers: Array[int] = []) -> void:
	if is_local(spawn_type):
		_spawn_local_entity(gpos, spawn_type, modifiers)
		return
	
	if multiplayer.is_server():
		_spawn_online_entity(gpos, spawn_type, modifiers)

func _spawn_online_entity(gpos: Vector2, spawn_type: int, modifiers: Array[int]) -> void:
	var spawn_rate :float = get_spawnrate(spawn_type)
	var rand_float :float = randf()
	if rand_float > spawn_rate:
		return
	
	if unused_entities.has(spawn_type) && gpos != Vector2(-1, -1):
		if unused_entities[spawn_type].size() > 0:
			var node: Entity = unused_entities[spawn_type].pop_back()
			node.rpc("enable", gpos, modifiers)
			return
	
	var node :Node = spawn([gpos, spawn_type])
	
	if node is Entity:
		if gpos == Vector2(-1, -1):
			node.rpc("disable")
			add_node_to_unused(node)
		else:
			node.rpc("enable", gpos, modifiers)
	add_node_to_spawned(node)

func _online_spawner_function(data: Array) -> Node:
	if !entity_prefabs.has(data[1]):
		printerr("No entity prefab for entity with type : %s" % data[1])
		return entity_prefabs[0].instantiate()
	
	var e :Entity = entity_prefabs[data[1]].instantiate()
	
	return e

#endregion


func get_spawn_amount(type: SpawnType) -> int:
	match type:
		SpawnType.ENEMY_MUSHROOM, SpawnType.ENEMY_TRUNK:
			return 15
		SpawnType.COLLECTABLE_APPLE:
			return 50
		SpawnType.TRAP_SPIKE:
			return 40
		_:
			return 20

#region Entity & Map Pruning
func clear_unused_children() -> void:
	if !MenuHandler.is_game_visible():
		return
	_clear_unused_local_children()
	
	if multiplayer.is_server():
		_clear_unused_multiplayer_children()
	
func _clear_unused_multiplayer_children() -> void:
	var lowest_player :Player = get_lowest_player()
	if not lowest_player:
		return
		
	var cleared :int = 0
	var disabled :int = 0
	
	for child: Node in map_gen_node.get_children():
		if child is not Node2D or child is Player:
			continue
		
		if child.global_position.y > lowest_player.global_position.y + bottom_safe_distance * 3:
			cleared += 1
			child.queue_free()
	
	for child: Node in spawn_node.get_children():
		if child is not Node2D or child is Player:
			continue
		
		
		
		if child.global_position.y > lowest_player.global_position.y + bottom_safe_distance:
			if child is Entity:
				if child.is_disabled:
					continue
				
				disabled += 1
				child.rpc("disable")
				add_node_to_unused(child)
			else:
				cleared += 1
				child.queue_free()
	print("Cleared a total of %s objects" % cleared)
	print("Disabled %s networked objects" % disabled)

func _clear_unused_local_children() -> void:
	var lowest_player :Player = get_lowest_player()
	if not lowest_player:
		return
	
	var disabled :int = 0
	
	var local_children :Array[Node] = local_spawn_node.get_children()
	for child: Node in local_children:
		if child is Entity:
			if child.is_disabled:
				continue
			
			if child.global_position.y > lowest_player.global_position.y + bottom_safe_distance:
				disabled += 1
				child.disable()
				add_node_to_unused(child)
	
	print("Disabled %s local objects" % disabled)

func get_lowest_player() -> Player:
	var players :Array[Node] = get_tree().get_nodes_in_group("Players")
	if players.is_empty():
		return null
	
	var lowest_player :Player = players[0]
	for p:Player in players:
		if p.dead:
			continue

		if p.global_position.y > lowest_player.global_position.y:
			lowest_player = p
	
	return lowest_player

func _on_prespawn_entities() -> void:
	for type in entity_prefabs.keys():
		if !is_local(type) && !multiplayer.is_server():
			continue
		for i:int in range(get_spawn_amount(type)):
			_on_spawn_entity(Vector2(-1, -1), type)

func _on_clear_entities() -> void:
	spawned_entities.clear()
	unused_entities.clear()
	
	for child in local_spawn_node.get_children():
		child.queue_free()
	
	if multiplayer.is_server():
		for child in spawn_node.get_children():
			child.queue_free()

#endregion


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	spawn_function = _online_spawner_function
	GameManager.spawn_entity.connect(_on_spawn_entity)
	GameManager.prespawn_entities.connect(_on_prespawn_entities)
	GameManager.clear_entities.connect(_on_clear_entities)
	GameManager.server_reset.connect(_on_server_reset)
	GameManager.client_reset.connect(_on_client_reset)
	Performance.add_custom_monitor("game/Total_Entities", get_entity_count, [[]])
	Performance.add_custom_monitor("game/enemies", get_entity_count, [[SpawnType.ENEMY_MUSHROOM, SpawnType.ENEMY_TRUNK]])
	Performance.add_custom_monitor("game/Traps", get_entity_count, [range(SpawnType.TRAP_SPIKE, SpawnType.TRAP_POWER_TRAMPOLINE)])
	Performance.add_custom_monitor("game/Collectables", get_entity_count, [[SpawnType.COLLECTABLE_APPLE]])




func _process(delta: float) -> void:
	if seconds_since_clear < seconds_between_clear:
		seconds_since_clear += delta
	else:
		seconds_since_clear = 0.0
		clear_unused_children()

#region Helper Functions

func get_entity_count(included_types: Array) -> int:
	var total_entites :int = 0
	for type:int in spawned_entities.keys():
		if included_types.has(type) or included_types.is_empty():
			total_entites += spawned_entities[type].size()
	return total_entites

func get_spawnrate(spawn_type: int) -> float:
	match spawn_type:
		SpawnType.ENEMY_MUSHROOM, SpawnType.ENEMY_TRUNK:
			return min(GameManager.get_difficulty_value("enemy_spawn_rate"), 1.0)
		SpawnType.COLLECTABLE_APPLE:
			return min(GameManager.get_difficulty_value("collectable_spawn_rate"), 1.0)
	
	return 1.0

func add_node_to_spawned(node: Entity) -> void:
	var type :SpawnType = node.entity_type
	if !spawned_entities.has(type):
		spawned_entities.set(type, [])
	
	spawned_entities[type].append(node)

func add_node_to_unused(node: Entity) -> void:
	var type :SpawnType = node.entity_type
	if !unused_entities.has(type):
		unused_entities.set(type, [])
	
	unused_entities[type].append(node)

#endregion
