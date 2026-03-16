extends Node2D

@export var top_safe_distance :int = 500
@export var bottom_safe_distance :int = 1500
@export var initial_height :int = 360
@export var multiplayer_spawner :MultiplayerSpawner

var px_per_tile :int = 16
var height :float = 0
var current_connection_type :MapFile.ConnectionType

func _ready() -> void: 
	GameManager.reset_game.connect(clear_map)
	GameManager.spawn_level.connect(_on_spawn_level)
	multiplayer_spawner.spawn_function = spawn_map_prefab

func clear_map() -> void:
	for child: Node in get_children():
		child.queue_free()
	height = initial_height
	current_connection_type = MapFile.ConnectionType.TYPE_A

func _on_spawn_level() -> void:
	height = initial_height
	spawn_map_file(Maps.get_start_map())

func spawn_map_section(map_section: Array[MapFile]) -> void:
	for map_file in map_section:
		spawn_map_file(map_file)

func spawn_map_file(map_file: MapFile) -> void:
	current_connection_type = map_file.top_connection_type
	var map_node :Node2D = multiplayer_spawner.spawn([map_file.prefab.resource_path, get_map_global_position()])

	height -= get_height_from_map_instance(map_node)

func next_map_section() -> void:
	var section :Array[MapFile] = Maps.get_next_map_section(current_connection_type)
	spawn_map_section(section)

func get_height_from_map_instance(node: Node2D) -> float:
	var terrain_node :TileMapLayer = node.get_node("TerrainTiles")
	var height_in_tiles :float = terrain_node.get_used_rect().size.y
	var height_in_pixels :float = height_in_tiles * px_per_tile
	return height_in_pixels

func get_map_global_position() -> Vector2:
	return position + Vector2(0, height)

func _process(delta: float) -> void:
	if multiplayer.has_multiplayer_peer() && multiplayer.is_server() != true:
		return

	var players :Array[Node] = get_tree().get_nodes_in_group("Players")
	if players.is_empty():
		return
	
	var global_height :float = height * global_scale.y
	for p:Node2D in players:
		if p.global_position.y < global_height + top_safe_distance:
			next_map_section()
			
			for child: Node in get_children():
				if child is not Node2D or players.has(child):
					return
				
				if child.global_position.y > p.global_position.y + bottom_safe_distance:
					child.queue_free()
				

func spawn_map_prefab(data: Array) -> Node: # Array[ressource_path, gpos, ]
	var map_node :Node2D = load(data[0]).instantiate()
	
	var terrain_node :TileMapLayer = map_node.get_node("TerrainTiles")
	var terrain_rect :Rect2i = terrain_node.get_used_rect()
	var neg_height_vector :Vector2 = Vector2(terrain_rect.position.x, terrain_rect.end.y) * px_per_tile
	neg_height_vector += terrain_node.position
	map_node.position = data[1] - neg_height_vector
	return map_node
