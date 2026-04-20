extends HBoxContainer

signal map_load_request(file: MapFile, assigned_map_arr_index: int)

var assigned_map_arr_index :int
@export var assigned_map :MapFile:
	set(value):
		assigned_map = value
		_update_labels()
@onready var load_button: Button = %load_button
@onready var filename_label: Label = %filename_label
@onready var map_type_label: Label = %map_type_label

func _ready() -> void:
	load_button.pressed.connect(_on_load_pressed)
	_update_labels()

func _update_labels() -> void:
	if not filename_label or not map_type_label:
		return
	
	if not assigned_map:
		load_button.disabled = true
		return
	
	filename_label.text = assigned_map.resource_path.get_file()
	var type :int = assigned_map.type
	
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

func _on_load_pressed() -> void:
	map_load_request.emit(assigned_map, assigned_map_arr_index)
