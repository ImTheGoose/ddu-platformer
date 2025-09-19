extends Node

signal hide_all_menus
signal show_menu(target: String)
signal toggle_game_visibillity(isVisible: bool)

var game_visible = false

func is_game_visible() -> bool:
	return game_visible

func _game_visible_changed(isVisible):
	game_visible = isVisible

func _ready() -> void:
	toggle_game_visibillity.connect(_game_visible_changed)	
