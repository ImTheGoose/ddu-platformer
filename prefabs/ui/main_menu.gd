extends GameMenu


func _on_start_game_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("start_game_menu")
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	GameManager.quit_game()
	pass # Replace with function body.


func _on_settings_menu_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("settings_menu")
	pass # Replace with function body.


func _on_shop_menu_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("shop_menu")
	pass # Replace with function body.
