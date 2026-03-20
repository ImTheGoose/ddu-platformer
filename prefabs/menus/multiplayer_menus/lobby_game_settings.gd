extends VBoxContainer

@onready var diff_label: Label = %difficulty_label
@onready var diff_option: OptionButton = %difficulty_option
@onready var rounds_label: Label = %rounds_label
@onready var rounds_option: OptionButton = %rounds_option
@onready var collission_label: Label = %collission_label
@onready var collission_option: OptionButton = %collission_option
@onready var gamemode_label: Label = %gamemode_label
@onready var gamemode_option: OptionButton = %gamemode_option

func _ready() -> void:
	GameManager.game_settings_changed.connect(_on_game_settings_changed)
	multiplayer.connected_to_server.connect(refresh_settings)
	
	diff_option.item_selected.connect(_on_difficulty_selected)
	refresh_settings()

func _on_difficulty_selected(index: int) -> void:
	GameManager.set_difficulty(index)
	GameManager.sync_settings_to_peers()
	return

func _on_game_settings_changed() -> void:
	refresh_settings()

func refresh_settings() -> void:
	if multiplayer.is_server():
		diff_option.visible = true
		rounds_option.visible = true
		collission_option.visible = true
		gamemode_option.visible = true
		diff_label.text = "Difficulty: "
		rounds_label.text = "Rounds to Win: "
		collission_label.text = "Collissions: "
		gamemode_label.text = "Gamemode: "
		
	else:
		diff_option.visible = false
		rounds_option.visible = false
		collission_option.visible = false
		gamemode_option.visible = false
		diff_label.text = "Difficulty: %s" % diff_option.get_item_text(GameManager.get_difficulty())
		rounds_label.text = "Rounds to Win: 1 round"
		collission_label.text = "Collissions: enabled"
		gamemode_label.text = "Gamemode: Standard"
	return
