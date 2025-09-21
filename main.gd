extends Node

func _ready() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.toggle_game_visibillity.emit(false)
	MenuManager.show_menu.emit("main_menu")
