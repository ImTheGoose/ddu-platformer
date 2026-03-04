extends Node2D

@export var start_map :MapInfo
@export var map_arr :Array[MapInfo]
@onready var map_arr_full = map_arr.duplicate()
@export var transition_arr :Array[MapInfo]
@export var safe_zone :int = 0

var px_per_tile :int = 16
var height :float = 0
var current_connection_type :MapInfo.connection_type

func _ready() -> void: 
	if map_arr.is_empty():
		map_arr = transition_arr.duplicate()
		map_arr_full = map_arr.duplicate()
	
	GameManager.on_reset_game.connect(_clear_map)
	_insert_map(start_map, _get_map_global_position())
	return

func _process(delta: float) -> void:
	_update_view_zone()

func _clear_map():
	for child in get_children():
		child.queue_free()
	height = 360
	current_connection_type = MapInfo.connection_type.typeA
	_insert_map(start_map, _get_map_global_position())

func _get_part() -> MapInfo:
	if map_arr.is_empty():
		map_arr = map_arr_full.duplicate()
	
	map_arr.shuffle()
	var part = map_arr.pop_front()
	
	return part

func _get_transition_part(from: MapInfo.connection_type, to: MapInfo.connection_type) -> MapInfo:
	var parts = _get_matching_transition_parts(from, to)
	if parts.is_empty(): ##If no transitions exist. Transition to a type that has a transition for all. (TypeC)
		_insert_transition(from, MapInfo.connection_type.typeC)
		return _get_matching_transition_parts(MapInfo.connection_type.typeC, to)[0]
	
	var part = parts.pick_random()
	
	return part

func _get_matching_transition_parts(from: MapInfo.connection_type, to: MapInfo.connection_type) -> Array[MapInfo]:
	var arr :Array[MapInfo] = []
	for t in transition_arr:
		if t.start_connection == from && t.end_connection == to:
			arr.append(t)
	
	return arr

func _insert_transition(from: MapInfo.connection_type, to: MapInfo.connection_type):
	var trans_part = _get_transition_part(from, to)
	_insert_map(trans_part, _get_map_global_position())
	
func _next_map():
	var map_part = _get_part()
	
	if map_part.start_connection != current_connection_type:
		_insert_transition(current_connection_type, map_part.start_connection)
	
	_insert_map(map_part, _get_map_global_position())


func _get_map_global_position():
	return position + Vector2(0, height)

func _insert_map(mapInfo: MapInfo, gpos: Vector2) -> void:
	current_connection_type = mapInfo.end_connection
	var m :Node2D = mapInfo.prefab.instantiate()
	add_child(m)
	
	var terrain_node :TileMapLayer = m.get_node("TerrainTiles")
	var rect :Rect2i = terrain_node.get_used_rect()
	var neg_height_vector = Vector2(rect.position.x, rect.end.y) * px_per_tile
	neg_height_vector += Vector2(terrain_node.position.x, terrain_node.position.y)
	m.position = gpos - neg_height_vector
	height -= _get_height_from_instance(m)

func _update_view_zone():
	var cam_gpos = get_viewport().get_camera_2d().global_position
	var cam_rect = get_viewport_rect()
	var cam_rect_global_end = cam_gpos + cam_rect.size
	var global_height = height * global_scale.y
	if global_height > cam_gpos.y - safe_zone:
		_next_map()
	
	for child: Node2D in get_children():
		if child.global_position.y > cam_rect_global_end.y + safe_zone:
			child.queue_free()


func _get_height_from_instance(inst: Node2D) -> float:
	var terrain_node :TileMapLayer = inst.get_node("TerrainTiles")
	var size_in_tiles = terrain_node.get_used_rect().size.y
	var size = size_in_tiles * px_per_tile
	var h = size
	return h
