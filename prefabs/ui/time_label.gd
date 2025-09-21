extends RichTextLabel

@export var prefix = "Time: "
var time = 0

func _ready() -> void:
	MenuManager.toggle_game_visibillity.connect(_toggle_visible)

func _process(delta: float) -> void:	
	if GameManager.game_paused:
		return
	
	match GameManager.game_state:
		GameManager.state.running:
			time += delta
		GameManager.state.pregame:
			time = 0
	
	text = prefix + str(int(time))

func _toggle_visible(isVisible):
	visible = isVisible
