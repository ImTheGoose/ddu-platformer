extends PanelContainer

class_name LevelButton

@export var level_num :int = 0
@onready var button_index_label: Label = %button_index_label
@onready var play_level_button: Button = %play_level_button

var level_offset :int = 0

func _ready() -> void:
	play_level_button.pressed.connect(_pressed)
	_update_state()

func _update_state() -> void:
	button_index_label.text = str(_get_index())
	if Levels.is_level_playable(_get_index()):
		play_level_button.disabled = false
		button_index_label.remove_theme_color_override("font_color")
	else:
		play_level_button.disabled = true
		button_index_label.remove_theme_color_override("font_color")
		button_index_label.add_theme_color_override("font_color", Color.WEB_GRAY)
		

func _get_index() -> int:
	return level_num + level_offset

func _update_level_index(index_offset: int) -> void:
	level_offset = index_offset
	_update_state()
	_on_foucs()

func _on_foucs() -> void:
	if not Levels.is_level_playable(_get_index()):
		return
	
	if DataManager.get_value("unlocked_level") == _get_index():
		play_level_button.grab_focus()

func _pressed() -> void:
	Levels.select_level(_get_index())
	MenuHandler.change_menu("level_overview_menu")
	#GameManager.play_level(_get_index())
