extends RichTextLabel

@export var prefix :String = "Time: "
var time :float = 0

func _ready() -> void:
	MenuHandler.changed_game_visibillity.connect(_on_game_visibillity_changed)
	GameManager.client_reset.connect(_on_client_reset)

func _on_client_reset() -> void:
	time = 0.0
	text = prefix + TimeFormat.get_time_string(time)

func _process(delta: float) -> void:	
	if GameManager.is_game_paused():
		return
	
	if GameManager.is_game_running():
		time += delta
	
	text = prefix + TimeFormat.get_time_string(time)

func _on_game_visibillity_changed(isVisible: bool ) -> void:
	visible = isVisible
