extends GameMenu

func _on_open_skin_button_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("shop_skin_menu")
	pass # Replace with function body.


func _on_back_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.


func _on_open_accent_button_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("shop_accent_menu")
	pass # Replace with function body.


func _on_open_theme_button_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("shop_theme_menu")
	pass # Replace with function body.
