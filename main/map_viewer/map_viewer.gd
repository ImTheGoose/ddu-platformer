extends Node

var spawn_height :int = 0
var px_per_tile :int = 16
var current_map_index: int = 0
var total_map_height: float = 0.0
var map_card :PackedScene = preload("uid://w2kt6mh7bu5g")
@onready var map_card_list: VBoxContainer = %map_card_list
@onready var overview_panel: PanelContainer = $CanvasLayer/Control/overview_panel
@onready var loaded_map_container: Node2D = %loaded_map_container
@onready var height_slider: VSlider = %height_slider
@onready var zoom_slider: HSlider = %zoom_slider
@onready var zoom_to_fit: CheckButton = %zoom_to_fit
@onready var camera_2d: Camera2D = %Camera2D
@onready var filename_label: Label = %file_name_label
@onready var map_type_label: Label = %map_type_label

func _ready() -> void:
	_instatiate_cards()

func _instatiate_cards() -> void:
	for child in map_card_list.get_children():
		child.queue_free()
	
	var map_files :Array[MapFile] = Maps.loaded_map_files
	for i: int in range(map_files.size()):
		var map :MapFile = map_files.get(i)
		var card :Control = map_card.instantiate()
		card.assigned_map_arr_index = i
		card.assigned_map = map
		card.map_load_request.connect(_load_map)
		map_card_list.add_child(card)
	
func _load_map(file: MapFile, index: int) -> void:
	current_map_index = index
	
	for child in loaded_map_container.get_children():
		child.queue_free()

	filename_label.text = file.resource_path.get_file()
	var type :int = file.type
	
	map_type_label.text = str( MapFile.MapType.find_key(type))
	match type:
		MapFile.MapType.REGULAR_MAP:
			map_type_label.modulate = Color.CORAL
		MapFile.MapType.TRANSITION_MAP:
			map_type_label.modulate = Color.GREEN_YELLOW
		MapFile.MapType.START_MAP:
			map_type_label.modulate = Color.MEDIUM_PURPLE
		MapFile.MapType.END_MAP:
			map_type_label.modulate = Color.DEEP_SKY_BLUE
		_:
			map_type_label.modulate = Color.WHITE
	
	var map_node = file.prefab.instantiate()
	map_node.overwrite_spawner = true
	loaded_map_container.add_child(map_node)
	
	var terrain_node :TileMapLayer = map_node.get_node("TerrainTiles")
	var terrain_rect :Rect2i = terrain_node.get_used_rect()
	
	var neg_height_vector :Vector2 = Vector2(terrain_rect.position.x, terrain_rect.end.y) * px_per_tile
	neg_height_vector += terrain_node.position
	map_node.position = Vector2(0, spawn_height) - neg_height_vector
	
	total_map_height = terrain_rect.size.y * px_per_tile
	
	# Reset sliders
	height_slider.value = 0
	zoom_slider.value = 0
	
	# Set zoom limits
	var min_zoom = min(3.0, 1080 / total_map_height)
	
	height_slider.visible = total_map_height > (1080 / 3.0)
	zoom_slider.visible = height_slider.visible
	
	camera_2d.zoom = Vector2.ONE * 3.0
	
	if zoom_to_fit.button_pressed:
		_on_zoom_slider_value_changed(1)

	
	_on_height_slider_value_changed(height_slider.value)
	

func _on_previous_pressed() -> void:
	var index :int = current_map_index
	if index <= 0:
		index = Maps.loaded_map_files.size() - 1
	else:
		index -= 1
		
	_load_map(Maps.loaded_map_files.get(index), index)

func _on_overview_pressed() -> void:
	overview_panel.visible = !overview_panel.visible

func _on_next_pressed() -> void:
	var index :int = current_map_index
	if index >= Maps.loaded_map_files.size() - 1:
		index = 0
	else:
		index += 1
		
	_load_map(Maps.loaded_map_files.get(index), index)


func _on_height_slider_value_changed(value: float) -> void:
	var zoom = camera_2d.zoom.y
	var visible_height = 1080 / zoom
	
	# How much of the map is NOT visible
	var overspill = max(0.0, total_map_height - visible_height)
	
	# Bottom of the map in world space
	var map_bottom = spawn_height
	
	# Base camera Y so bottom is aligned
	var base_y = map_bottom - (visible_height / 2.0)
	
	# Apply scroll upward
	var offset = height_slider.value * overspill
	
	camera_2d.global_position.y = base_y - offset

func _on_zoom_slider_value_changed(value: float) -> void:
	var fit_height :float = 1080 / total_map_height
	
	var max_zoom :float = min(fit_height, 3.0)
	
	var final_zoom :float = lerp(3.0, max_zoom, value)
	
	camera_2d.zoom = Vector2(final_zoom, final_zoom)
	_on_height_slider_value_changed(height_slider.value)
