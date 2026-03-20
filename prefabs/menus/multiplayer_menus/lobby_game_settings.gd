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
	rounds_option.item_selected.connect(_on_rounds_selected)
	gamemode_option.item_selected.connect(_on_gamemode_selected)
	collission_option.item_selected.connect(_on_collissions_selected)
	refresh_settings()

func _on_collissions_selected(index: int) -> void:
	if index == 0:
		GameManager.set_collisions_enabled(false)
	else:
		GameManager.set_collisions_enabled(true)
	
	GameManager.sync_settings_to_peers()

func _on_gamemode_selected(index: int) -> void:
	GameManager.set_gamemode(index)
	GameManager.sync_settings_to_peers()

func _on_rounds_selected(index: int) -> void:
	GameManager.set_playing_rounds(rounds_option.get_item_id(index))
	GameManager.sync_settings_to_peers()

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
		diff_option.selected = GameManager.get_difficulty()
		
		rounds_option.selected = rounds_option.get_item_index(GameManager.get_playing_rounds())
		
		
	else:
		diff_option.visible = false
		rounds_option.visible = false
		collission_option.visible = false
		gamemode_option.visible = false
		diff_label.text = "Difficulty: %s" % diff_option.get_item_text(GameManager.get_difficulty())
		rounds_label.text = "Rounds to Win: %s" % rounds_option.get_item_text(rounds_option.get_item_index(GameManager.get_playing_rounds()))
		if GameManager.is_collissions_enabled():
			collission_label.text = "Collissions: enabled"
		else:
			collission_label.text = "Collissions: disabled"
		gamemode_label.text = "Gamemode: %s" % gamemode_option.get_item_text(GameManager.get_gamemode())
	return
