extends GameMenu


func _on_back_to_menu_pressed() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if !MenuManager.is_game_visible():
			return
			
		if GameManager.game_state == GameManager.state.dead:
			return
		
		if GameManager.is_game_paused():
			GameManager.pause_game(false)
			MenuManager.hide_all_menus.emit()
		else:
			GameManager.pause_game(true)
			MenuManager.show_menu.emit("pause_menu")
