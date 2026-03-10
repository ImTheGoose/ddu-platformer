extends GameMenu


func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("select_play_menu")


func _on_host_button_pressed() -> void:
	MenuHandler.change_menu("multiplayer_host_type_menu")


func _on_join_button_pressed() -> void:
	MenuHandler.change_menu("multiplayer_join_menu")
