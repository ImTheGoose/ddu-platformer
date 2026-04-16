extends GPUParticles2D

class_name ToggleableParticle 

## If visibillity should be updated in process. If not then will not be visible, unless set by script.
@export var process_updated :bool = true
@export var enabled_at_setting :ParticleAmount = ParticleAmount.MEDIUM

enum ParticleAmount {
	DISABLED,
	MINIMAL,
	MEDIUM,
	ALL,
}

func _ready() -> void:
	visibility_changed.connect(_on_visible_changed)
	_on_visible_changed()

func _on_visible_changed() -> void:
	var video_settings :Dictionary = DataManager.get_video_settings()
	var is_enabled :bool = true if video_settings.get("particle_amount", ParticleAmount.ALL) >= enabled_at_setting else false
	visible = is_enabled

func _process(delta: float) -> void:
	if process_updated:
		var video_settings :Dictionary = DataManager.get_video_settings()
		var is_enabled :bool = true if video_settings.get("particle_amount", ParticleAmount.ALL) >= enabled_at_setting else false
		visible = is_enabled
