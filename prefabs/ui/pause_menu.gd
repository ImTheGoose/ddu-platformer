extends GameMenu



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

func _hide():
	super()
	MenuManager.toggle_background_seperator.emit(false)

func _show(target):
	super(target)
	if target == menu_name:
		MenuManager.toggle_background_seperator.emit(true)

func _on_continue_game_pressed() -> void:
	GameManager.pause_game(false)
	MenuManager.hide_all_menus.emit()
	pass # Replace with function body.


func _on_restart_game_pressed() -> void:
	GameManager.pause_game(false)
	GameManager.reset_game()
	MenuManager.hide_all_menus.emit()
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	GameManager.pause_game(false)
	GameManager.reset_game()
	MenuManager.hide_all_menus.emit()
	MenuManager.toggle_game_visibillity.emit(false)
	MenuManager.show_menu.emit("main_menu")
	
	pass # Replace with function body.
