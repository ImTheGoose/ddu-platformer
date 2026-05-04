extends Control

@export var time_label :RichTextLabel
var time_original_text :String
@export var height_label :RichTextLabel
var height_original_text :String

func _ready() -> void:
	time_original_text = time_label.text
	height_original_text = height_label.text
		
	MenuHandler.changed_game_visibillity.connect(_on_game_visibillity_changed)
	GameManager.client_reset.connect(_on_client_reset)

func _on_client_reset() -> void:
	time_label.text = time_original_text % Format.get_time_string(0)
	height_label.text = height_original_text % Format.get_height_string(0)
	
	if GameManager.is_playing_singleplayer():
		height_label.visible = !GameManager.is_playing_level()
		time_label.visible = true
	else:
		height_label.visible = false
		time_label.visible = true

func _process(delta: float) -> void:	
	if GameManager.is_game_paused():
		return
	
	var time_passed :float = GameManager.round_seconds_passed
	time_label.text = time_original_text % Format.get_time_string(time_passed, 0.1)
	
	var height_reached :float = Stats.get_recording_value(Stats.StatType.HEIGHT_REACHED)
	height_label.text = height_original_text % Format.get_height_string(height_reached)

func _on_game_visibillity_changed(isVisible: bool ) -> void:
	visible = isVisible
