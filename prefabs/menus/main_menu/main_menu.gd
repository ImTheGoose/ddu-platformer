extends GameMenu


func _on_start_game_pressed() -> void:
	MenuHandler.change_menu("start_game_menu")
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	GameManager.quit_game()
	pass # Replace with function body.


func _on_settings_menu_pressed() -> void:
	MenuHandler.change_menu("settings_menu")
	pass # Replace with function body.


func _on_shop_menu_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu")
	pass # Replace with function body.


func _on_statistic_menu_pressed() -> void:
	MenuHandler.change_menu("statistics_menu")
	pass # Replace with function body.
