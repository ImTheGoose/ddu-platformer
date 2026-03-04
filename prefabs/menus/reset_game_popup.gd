extends GameMenu


func _on_delete_data_pressed() -> void:
	DataManager.clear_game_data()
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("settings_menu")
	pass # Replace with function body.


func _on_cancel_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("settings_menu")
	pass # Replace with function body.
