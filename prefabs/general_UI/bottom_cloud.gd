extends GPUParticles2D

func _ready() -> void:
	MenuHandler.changed_game_visibillity.connect(_on_game_visibillity_changed)
	GameManager.on_start_game.connect(_start_emitting)
	GameManager.on_reset_game.connect(_stop_emitting)

func _is_particles_enabled() -> bool:
	var video_settings :Dictionary = DataManager.get_video_settings()
	return video_settings.particles_enabled

func _on_game_visibillity_changed(isVisible: bool) -> void:
	if _is_particles_enabled():
		visible = isVisible
	else:
		visible = false

func _stop_emitting() -> void:
	restart()
	emitting = false

func _start_emitting() -> void:
	if _is_particles_enabled():
		emitting = true
