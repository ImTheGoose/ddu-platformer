extends GameMenu

@onready var difficulty_dropdown = $difficulty_dropdown

func _ready() -> void:
	super()
	var dif = GameManager.get_difficulty()
	difficulty_dropdown.selected = difficulty_dropdown.get_item_index(dif)

func _on_start_game_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.toggle_game_visibillity.emit(true)
	GameManager.reset_game()
	pass # Replace with function body.


func _on_back_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.


func _on_difficulty_dropdown_item_selected(index: int) -> void:
	GameManager.set_difficulty(difficulty_dropdown.get_item_id(index))
	pass # Replace with function body.
