extends GameMenu


func _on_start_game_pressed() -> void:
	MenuHandler.change_menu("select_play_menu")


func _on_quit_game_pressed() -> void:
	GameManager.quit_game()


func _on_settings_menu_pressed() -> void:
	MenuHandler.change_menu("settings_menu", true)


func _on_shop_menu_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu", true)


func _on_statistic_menu_pressed() -> void:
	MenuHandler.change_menu("statistics_menu")
