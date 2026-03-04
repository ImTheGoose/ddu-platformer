extends Node2D

func _process(delta: float) -> void:
	var video_settings :Dictionary = DataManager.get_video_settings()
	visible = video_settings.particles_enabled
