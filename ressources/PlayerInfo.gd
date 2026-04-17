extends Resource

class_name PlayerInfo

@export var PEER_ID :int = -1:
	set(value):
		PEER_ID = value
		peer_id_changed.emit()
		
@export var AVATAR_IMAGE :Image:
	set(value):
		AVATAR_IMAGE = value
		avatar_image_changed.emit()
		
@export var DISPLAY_NAME: String = "lan_placeholder":
	set(value):
		DISPLAY_NAME = value
		display_name_changed.emit(value)

@export var SELECTED_SKIN_NAME: String = "Osvald"
@export var SELECTED_OUTLINE_HEX: String = "#ffffff"

@export var assigned_input_configs :Array[InputConfig] = []:
	set(value):
		assigned_input_configs = value
		assigned_input_changed.emit()

signal cosmetics_changed()
signal display_name_changed(new_name: String)
signal avatar_image_changed()
signal assigned_input_changed()
signal peer_id_changed()

func _init(assigned_peer_id: int) -> void:
	PEER_ID = assigned_peer_id

func get_movement_axis() -> float:
	var axis :float = 0.0
	for input: InputConfig in assigned_input_configs:
		axis += input.get_move_axis()
	
	if axis < 0.2 && axis > -0.2:
		return 0
	
	return clamp(axis, -1.0, 1.0)

func is_jump_event_from_inputs(event: InputEvent) -> bool:
	for input: InputConfig in assigned_input_configs:
		if input.is_event_from_jump_input(event):
			return true
	return false

func get_input_from_event(event: InputEvent) -> InputConfig:
	for input_config: InputConfig in assigned_input_configs:
		if input_config.is_event_input_activation(event):
			return input_config
	return null

func add_input(input: InputConfig) -> void:
	assigned_input_configs.append(input)
	assigned_input_changed.emit()

func remove_input(input: InputConfig) -> void:
	assigned_input_configs.erase(input)
	assigned_input_changed.emit()
	
	
