extends GameMenu

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("restart"):
		if GameManager.game_state == GameManager.state.dead:
			MenuManager.hide_all_menus.emit()
			GameManager.reset_game()

func _hide():
	super()
	MenuManager.toggle_background_seperator.emit(false)

func _show(target):
	super(target)
	if target == menu_name:
		MenuManager.toggle_background_seperator.emit(true)

func _on_play_again_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	GameManager.reset_game()
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.toggle_game_visibillity.emit(false)
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.
