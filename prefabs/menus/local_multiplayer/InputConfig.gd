extends Resource

class_name InputConfig 

@export var activate_actions :Array[String] = []
@export var jump_action :String = ""
@export var move_left_action :String = ""
@export var move_right_action :String = ""
@export var joypad_id :int = -1
@export var input_icon_bbcode :String = ""

func get_icon_bbcode() -> String:
	match joypad_id:
		0:
			return "C1 "
		1:
			return "C2 "
		2:
			return "C3 "

	return input_icon_bbcode

func is_event_input_activation(event: InputEvent) -> bool:
	if event is InputEventJoypadButton:
		if event.device == joypad_id:
			if event.button_index == JOY_BUTTON_START:
				return true
	
	if not activate_actions.is_empty():
		for action in activate_actions:
			if event.is_action(action):
				return true
	return false

func get_move_axis() -> float:
	if joypad_id != -1:
		var axis :float = Input.get_joy_axis(joypad_id, JOY_AXIS_LEFT_X)
		if axis < 0.2 && axis > -0.2:
			return 0
		return axis
	
	if move_left_action != "" && move_right_action != "":
		return Input.get_axis(move_left_action, move_right_action)
	return 0

func is_event_from_jump_input(event: InputEvent) -> bool:
	if event is InputEventJoypadButton:
		if event.device == joypad_id:
			if event.button_index == JOY_BUTTON_A:
				return true
	
	if jump_action != "":
		if event.is_action(jump_action):
			return true
	
	return false
