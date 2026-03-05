extends Node

func _ready() -> void:
	MenuHandler.hide_game()
	if not DataManager.get_value("changelog_seen"):
		MenuHandler.change_menu("changelog")
	else:
		MenuHandler.change_menu("main_menu")
