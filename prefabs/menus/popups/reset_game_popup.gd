extends GameMenu


func _on_delete_data_pressed() -> void:
	DataManager.clear_game_data()
	Steamworks.reset_steam_stats()
	Steamworks.store_steam_data()
	MenuHandler.change_menu(MenuHandler.get_previous_menu())


func _on_cancel_pressed() -> void:
	MenuHandler.change_menu("settings_menu")
