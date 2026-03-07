extends GameMenu

func _input(event: InputEvent) -> void:
	if event.is_action("escape") && event.is_pressed():
		if !MenuHandler.is_game_visible():
			return
		
		if GameManager.get_state() == GameManager.STATE.DEAD:
			return
		
		if GameManager.is_game_paused():
			GameManager.pause_game(false)
			MenuHandler.hide_all_menus()
		else:
			GameManager.pause_game(true)
			MenuHandler.change_menu("pause_menu")


func _on_continue_game_pressed() -> void:
	GameManager.pause_game(false)
	MenuHandler.hide_all_menus()


func _on_restart_game_pressed() -> void:
	GameManager.restart_game()


func _on_back_to_menu_pressed() -> void:
	GameManager.quit_to_main()
	
