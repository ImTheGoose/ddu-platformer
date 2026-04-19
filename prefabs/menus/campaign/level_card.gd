extends PanelContainer

class_name LevelButton

@export var level_num :int = 0
@onready var button_index_label: RichTextLabel = %button_index_label
var original_button_text :String
@onready var play_level_button: Button = %play_level_button

var level_offset :int = 0

func _ready() -> void:
	original_button_text = button_index_label.text
	play_level_button.pressed.connect(_pressed)

func _update_state() -> void:
	if Levels.is_level_playable(_get_index()):
		play_level_button.disabled = false
		button_index_label.remove_theme_color_override("font_color")
		var level_file :LevelFile = Levels.get_level(_get_index())
		var level_time :float = Levels.get_level_time(_get_index())
		var color_string :String = level_file.get_time_color_string(level_time)
		button_index_label.text = original_button_text % [color_string, color_string, _get_index()]
	else:
		play_level_button.disabled = true
		button_index_label.remove_theme_color_override("font_color")
		button_index_label.add_theme_color_override("font_color", Color.WEB_GRAY)
		button_index_label.text = original_button_text % ["white", "white", _get_index()]
	
	button_index_label.bbcode_enabled = true
		

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
