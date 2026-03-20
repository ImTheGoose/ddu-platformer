extends GameMenu

func _on_open_skin_button_pressed() -> void:
	MenuHandler.change_menu("shop_skin_menu")


func _on_back_pressed() -> void:
	MenuHandler.change_menu(MenuHandler.get_previous_menu())


func _on_open_accent_button_pressed() -> void:
	MenuHandler.change_menu("shop_accent_menu")


func _on_open_theme_button_pressed() -> void:
	MenuHandler.change_menu("shop_theme_menu")
