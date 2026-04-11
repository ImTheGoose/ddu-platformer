extends GameMenu

@onready var level_label: Label = $VBoxContainer/PanelContainer/VBoxContainer/level_label
var original_level_text :String
@onready var highscore_label: RichTextLabel = %highscore_label
var original_highscore_text :String
@onready var medals_label: RichTextLabel = %medals_label
var original_medals_text :String

func _ready() -> void:
	super()
	original_level_text = level_label.text
	original_highscore_text = highscore_label.text
	original_medals_text = medals_label.text

func _on_show() -> void:
	_refresh_values()

func _refresh_values() -> void:
	var level_index :int = Levels.get_level_index()
	var level_file :LevelFile = Levels.get_level(level_index)
	
	level_label.text = original_level_text % level_index
	
	var gold_seconds :String = TimeFormat.get_time_string(level_file.gold_medal_seconds)
	var silver_seconds :String = TimeFormat.get_time_string(level_file.silver_medal_seconds)
	var bronze_seconds :String = TimeFormat.get_time_string(level_file.bronze_medal_seconds)
	
	medals_label.text = original_medals_text % [gold_seconds, silver_seconds, bronze_seconds]

func _on_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("level_select_menu")
