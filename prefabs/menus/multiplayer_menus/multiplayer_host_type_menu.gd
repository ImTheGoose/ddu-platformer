extends GameMenu


func _on_local_lan_button_pressed() -> void:
	Lobby.create_lan_server()


func _on_online_button_pressed() -> void:
	Lobby.create_steam_lobby()


func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("multiplayer_select_menu")
