extends Control

class_name GameMenu 

@export var menu_name :String
@export var seperate_from_game :bool = false
@export var initial_focus :Control
@export var server_initial_focus :Control
@export var back_button :Button

func _ready() -> void:
	MenuHandler.register_menu(menu_name, self)
	
	if !initial_focus:
		print("Missing initial focus on " + menu_name)


func show_menu() -> void:
	visible = true
	_on_show()
	if initial_focus:
		if server_initial_focus && multiplayer.is_server():
			server_initial_focus.grab_focus()
		else:
			initial_focus.grab_focus()
	
	if seperate_from_game && MenuHandler.is_game_visible():
		MenuHandler.show_background_seperator()
	pass

func hide_menu() -> void:
	visible = false
	_on_hide()
	if seperate_from_game:
			MenuHandler.hide_background_seperator()

func go_back() -> void:
	if !visible:
		return
	
	if back_button:
		back_button.pressed.emit()


func _on_show() -> void:
	pass

func _on_hide() -> void:
	pass
