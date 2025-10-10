extends Node

func _ready() -> void:
	MenuManager.hide_all_menus.emit()
	if not DataManager.get_value("changelog_seen"):
		MenuManager.toggle_game_visibillity.emit(false)
		MenuManager.show_menu.emit("changelog")
	else:
		MenuManager.toggle_game_visibillity.emit(false)
		MenuManager.show_menu.emit("main_menu")
