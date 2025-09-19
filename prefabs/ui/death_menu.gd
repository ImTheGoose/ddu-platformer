extends GameMenu


func _on_play_again_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	GameManager.reset_game()
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.toggle_game_visibillity.emit(false)
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.
