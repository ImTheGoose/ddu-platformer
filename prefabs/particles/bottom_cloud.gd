extends ToggleableParticle

func _ready() -> void:
	super()
	GameManager.client_reset.connect(_on_client_reset)

func _on_client_reset() -> void:
	restart()
	emitting = false

func _process(delta: float) -> void:
	super(delta)
	if GameManager.is_game_running():
		emitting = true
	else:
		emitting = false
