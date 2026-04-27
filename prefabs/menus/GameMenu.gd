extends Control

class_name GameMenu 

@export var menu_name :String
@export var seperate_from_game :bool = false
@export var initial_focus :Control
@export var server_initial_focus :Control
@export var back_button :Button
var initial_process :ProcessMode

func _ready() -> void:
	MenuHandler.register_menu(menu_name, self)
	initial_process = process_mode
	
	if !initial_focus:
		print("Missing initial focus on " + menu_name)


func show_menu() -> void:
	process_mode = initial_process
	visible = true
	_on_show()
	_try_focus_grap()
	
	if seperate_from_game && MenuHandler.is_game_visible():
		MenuHandler.show_background_seperator()
	pass

func hide_menu() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	_on_hide()
	if seperate_from_game:
			MenuHandler.hide_background_seperator()

func _try_focus_grap() -> void:
	if initial_focus:
		if server_initial_focus && multiplayer.is_server():
			server_initial_focus.grab_focus()
		else:
			initial_focus.grab_focus()

func go_back() -> void:
	if !visible:
		return
	
	if back_button:
		back_button.pressed.emit()


func _on_show() -> void:
	pass

func _on_hide() -> void:
	pass
