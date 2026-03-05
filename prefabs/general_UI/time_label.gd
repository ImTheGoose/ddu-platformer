extends RichTextLabel

@export var prefix :String = "Time: "
var time :float = 0

func _ready() -> void:
	MenuHandler.changed_game_visibillity.connect(_on_game_visibillity_changed)

func _process(delta: float) -> void:	
	if GameManager.game_paused:
		return
	
	match GameManager.get_state():
		GameManager.STATE.PLAYING:
			time += delta
		GameManager.STATE.PREGAME:
			time = 0
	
	text = prefix + TimeFormat.get_time_string(time)

func _on_game_visibillity_changed(isVisible: bool ) -> void:
	visible = isVisible
