extends Control

class_name GameMenu 

@export var menu_name :String
@export var intial_focus_button :Button

func _ready() -> void:
	MenuManager.hide_all_menus.connect(_hide)
	MenuManager.show_menu.connect(_show)

func _show(target: String) -> void:
	if target == menu_name:
		visible = true
		intial_focus_button.grab_focus.call_deferred()

func _hide() -> void:
	visible = false
