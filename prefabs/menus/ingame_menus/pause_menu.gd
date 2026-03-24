extends GameMenu

@onready var restart_button :Button = %restart_game
@onready var back_to_main :Button = %back_to_menu
@onready var back_to_lobby :Button = %back_to_lobby
@onready var leave_game_button: Button = %leave_game_button

func _on_show() -> void:
	if !multiplayer.is_server():
		restart_button.disabled = true
		restart_button.visible = false
		back_to_lobby.visible = false
		back_to_lobby.disabled = true
		back_to_main.visible = false
		back_to_main.disabled = true
		leave_game_button.visible = true
		leave_game_button.disabled = false
		return
	
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		back_to_lobby.visible = false
		back_to_lobby.disabled = true
		back_to_main.visible = true
		back_to_main.disabled = false

	else:
		back_to_lobby.visible = true
		back_to_lobby.disabled = false
		back_to_main.visible = false
		back_to_main.disabled = true

	leave_game_button.visible = false
	leave_game_button.disabled = true
	restart_button.disabled = false
	restart_button.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action("pause_game") && event.is_pressed():
		if !MenuHandler.is_game_visible():
			return
		
		if GameManager.get_state() == GameManager.STATE.POST_GAME:
			return
		
		if GameManager.is_game_paused() or MenuHandler.is_menu_visible("pause_menu"):
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
	

func _on_back_to_lobby_pressed() -> void:
	GameManager.return_to_lobby()


func _on_settings_button_pressed() -> void:
	MenuHandler.change_menu("settings_menu", true)


func _on_customize_button_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu", true)


func _on_leave_game_button_pressed() -> void:
	GameManager.quit_to_main()
