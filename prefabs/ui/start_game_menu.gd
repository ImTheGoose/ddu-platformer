extends GameMenu


func _on_start_game_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.toggle_game_visibillity.emit(true)
	GameManager.reset_game()
	pass # Replace with function body.


func _on_back_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.
