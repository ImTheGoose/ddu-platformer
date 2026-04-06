extends GameMenu

enum ValueType {
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_FORMATTED_TIME,
	TYPE_ID_TOTAL,
}

func _on_back_pressed() -> void:
	MenuHandler.change_menu("main_menu")
