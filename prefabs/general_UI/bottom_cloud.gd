extends GPUParticles2D

func _ready() -> void:
	MenuManager.toggle_game_visibillity.connect(_toggle_visible)
	GameManager.on_start_game.connect(_start_emitting)
	GameManager.on_reset_game.connect(_stop_emitting)

func _process(delta: float) -> void:
	var video_settings = DataManager.get_video_settings()
	visible = video_settings.particles_enabled
	if video_settings.particles_enabled == false:
		emitting = false

func _toggle_visible(isVisible):
	if isVisible:
		_start_emitting()
	else:
		_stop_emitting()


func _stop_emitting():
	restart()
	emitting = false

func _start_emitting():
	emitting = true
