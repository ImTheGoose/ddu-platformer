extends GameMenu


func _on_singleplayer_pressed() -> void:
	MenuHandler.change_menu("start_game_menu")
	pass # Replace with function body.


func _on_local_multiplayer_pressed() -> void:
	pass # Replace with function body.


func _on_online_multiplayer_pressed() -> void:
	MenuHandler.change_menu("multiplayer_select_menu")
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("main_menu")
	pass # Replace with function body.
