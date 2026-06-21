extends Resource

class_name InputConfig 

@export var activate_actions :Array[String] = []
@export var jump_action :String = ""
@export var move_left_action :String = ""
@export var move_right_action :String = ""
@export var joypad_id :int = -1

func get_icon_path() -> String:
	if joypad_id == -1:
		return "res://assets/icons/controllers/keyboard.png"
	
	var name: String = Input.get_joy_info(joypad_id).raw_name
	name = name.to_lower()
	if name.contains("xbox"):
		if name.containsn("360"):
			return "res://assets/icons/controllers/controller_xbox_360.png"
		if name.containsn("one"):
			return "res://assets/icons/controllers/controller_xbox_ONE.png"
		else:
			return "res://assets/icons/controllers/controller_xbox_X.png"
	if name.containsn("dualsense") or name.containsn("ps5"):
		return "res://assets/icons/controllers/controller_ps5.png"
	
	if name.containsn("dualshock") or name.containsn("ps4") or name.containsn("ps3"):
		return "res://assets/icons/controllers/controller_ps4.png"
	
	if name.containsn("nintendo") or name.containsn("switch"):
		return "res://assets/icons/controllers/controller_switch.png"
	
	return "res://assets/icons/controllers/controller_generic.png"

func get_icon_bbcode() -> String:
	return "[img height=1em]%s[/img]" % get_icon_path()

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
