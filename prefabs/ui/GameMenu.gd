extends Control

class_name GameMenu 

@export var menu_name :String

func _ready() -> void:
	MenuManager.hide_all_menus.connect(_hide)
	MenuManager.show_menu.connect(_show)

func _show(target):
	if target == menu_name:
		visible = true

func _hide():
	visible = false
