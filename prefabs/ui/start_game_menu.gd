extends GameMenu

@onready var difficulty_dropdown :OptionButton = $difficulty_dropdown
@onready var diffculty_stat_label :RichTextLabel = $difficulty_stats
@export var collectable_bbcode :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]"
@export var enemy_bbcode :String = "[img]res://assets/pixel_adventure_assets/Enemies/Mushroom/Icon (16x16).png[/img]"
@export var speed_bbcode :String = "[img]res://assets/pixel_adventure_assets/Other/dust (16x16).png[/img]"



func _ready() -> void:
	super()
	var dif = GameManager.get_difficulty()
	difficulty_dropdown.selected = difficulty_dropdown.get_item_index(dif)
	_refresh_stats()

func _refresh_stats():
	var tex :String = enemy_bbcode
	
	tex += str( int(GameManager.get_difficulty_value("enemy_spawn_rate") * 100)) + "%[br]"
	tex += collectable_bbcode
	tex += str( int(GameManager.get_difficulty_value("collectable_spawn_rate") * 100)) + "%[br]"
	tex += speed_bbcode
	tex += str( int(GameManager.get_difficulty_value("camera_speed") * 100)) + "%"
	print(tex)
	diffculty_stat_label.text = tex

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
	_refresh_stats()
	pass # Replace with function body.
