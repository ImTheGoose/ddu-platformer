extends GameMenu


func _on_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("level_select_menu")
