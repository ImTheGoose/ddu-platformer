extends Node2D

## If visibillity should be updated in process. If not then will not be visible, unless set by script.
@export var process_updated :bool = true

func _ready() -> void:
	visibility_changed.connect(_on_visible_changed)
	_on_visible_changed()

func _on_visible_changed() -> void:
	var video_settings :Dictionary = DataManager.get_video_settings()
	if !video_settings.particles_enabled:
		visible = false

func _process(delta: float) -> void:
	if process_updated:
		var video_settings :Dictionary = DataManager.get_video_settings()
		visible = video_settings.particles_enabled
