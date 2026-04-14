extends GameMenu

@onready var level_label: Label = $VBoxContainer/PanelContainer/VBoxContainer/level_label
var original_level_text :String
@onready var highscore_label: RichTextLabel = %highscore_label
var original_highscore_text :String
@onready var medals_label: RichTextLabel = %medals_label
var original_medals_text :String

@onready var next_button: Button = %next_button
@onready var replay_button: Button = %replay_button
@onready var play_button: Button = %play_button

func _ready() -> void:
	super()
	original_level_text = level_label.text
	original_highscore_text = highscore_label.text
	original_medals_text = medals_label.text
	next_button.pressed.connect(_on_next_pressed)
	replay_button.pressed.connect(_on_replay_pressed)
	play_button.pressed.connect(_on_play_pressed)

func _on_show() -> void:
	if MenuHandler.is_game_visible():
		next_button.visible = true
		next_button.disabled = false
		replay_button.visible = true
		replay_button.disabled = false
		play_button.visible = false
		play_button.disabled = true
		initial_focus = replay_button
	else:
		next_button.visible = false
		next_button.disabled = true
		replay_button.visible = false
		replay_button.disabled = true
		play_button.visible = true
		play_button.disabled = false
		initial_focus = play_button
	
	_refresh_values()

func _refresh_values() -> void:
	var level_index :int = Levels.get_level_index()
	var level_file :LevelFile = Levels.get_level(level_index)
	
	level_label.text = original_level_text % level_index
	
	var level_time :float = Levels.get_level_time(level_index)
	if level_time > 0:
		highscore_label.text = original_highscore_text % [_get_time_color(level_time), Format.get_time_string(level_time)]
	else:
		highscore_label.text = original_highscore_text % ["white", "None"]
	
	var gold_seconds :String = Format.get_time_string(level_file.gold_medal_seconds)
	var silver_seconds :String = Format.get_time_string(level_file.silver_medal_seconds)
	var bronze_seconds :String = Format.get_time_string(level_file.bronze_medal_seconds)
	
	medals_label.text = original_medals_text % [gold_seconds, silver_seconds, bronze_seconds]

func _get_time_color(time: float) -> String:
	var level_index :int = Levels.get_level_index()
	var level_file :LevelFile = Levels.get_level(level_index)
	if time <= level_file.gold_medal_seconds:
		return "goldenrod"
	
	if time <= level_file.silver_medal_seconds:
		return "silver"
	
	if time <= level_file.bronze_medal_seconds:
		return "chocolate"
	
	return "white"
	

func _on_next_pressed() -> void:
	var new_index :int = Levels.get_level_index() + 1
	if Levels.is_level_playable(new_index):
		Levels.select_level(new_index)
		GameManager.restart_game()
	else:
		GameManager.quit_to_main()

func _on_replay_pressed() -> void:
	GameManager.restart_game()

func _on_play_pressed() -> void:
	GameManager.prepare_game(true)

func _on_back_button_pressed() -> void:
	if MenuHandler.is_game_visible():
		GameManager.quit_to_main()
	else:
		MenuHandler.change_menu("level_select_menu")
