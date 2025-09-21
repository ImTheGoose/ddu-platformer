extends GameMenu

@onready var input_button_prefab = preload("res://prefabs/ui/input_button.tscn")
@onready var action_list = $PanelContainer/VBoxContainer/ScrollContainer/SettingsList/action_list

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"move_left": "Move left",
	"move_right": "Move right",
	"jump": "Jump",
	"escape": "Pause",
	"fullscreen_toggle": "Toggle Fullscreen"
}

func _ready() -> void:
	super()
	_load_keybindings_from_settings()
	_create_action_list()

func _load_keybindings_from_settings():
	var keybindings = DataManager.get_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])
	
	return


func _create_action_list():
	for child in action_list.get_children():
		child.queue_free()
	
	for action in input_actions:	
		var button = input_button_prefab.instantiate()
		var input_label = button.find_child("input_label")
		var action_label = button.find_child("action_label")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("input_label").text = "Press key to bind..."
	return

func _input(event):
	if is_remapping:
		if (event is InputEventKey || event is InputEventMouseButton && event.pressed):
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			DataManager.save_keybinding(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			if event is InputEventMouseButton:
				event.double_click = false
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()

func _update_action_list(button, event):
	button.find_child("input_label").text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_to_default_pressed() -> void:
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			DataManager.save_keybinding(action, events[0])
	_create_action_list()
	pass # Replace with function body.


func _on_back_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("settings_menu")
	pass # Replace with function body.
