extends GPUParticles2D

func _ready() -> void:
	MenuHandler.changed_game_visibillity.connect(_on_game_visibillity_changed)
	GameManager.on_start_game.connect(_start_emitting)
	GameManager.on_reset_game.connect(_stop_emitting)

func _process(delta: float) -> void:
	var video_settings :Dictionary = DataManager.get_video_settings()
	visible = video_settings.particles_enabled
	if video_settings.particles_enabled == false:
		emitting = false

func _on_game_visibillity_changed(isVisible: bool) -> void:
	if isVisible:
		_start_emitting()
	else:
		_stop_emitting()


func _stop_emitting() -> void:
	restart()
	emitting = false

func _start_emitting() -> void:
	emitting = true
