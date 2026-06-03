extends ColorRect

@export var anim :AnimationPlayer
var should_be_shown := false

func _ready() -> void:
	MenuHandler.changed_blackout_visibillity.connect(_on_visibillity_changed)
	anim.animation_finished.connect(_on_animation_finished)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func _on_viewport_size_changed() -> void:
	var rect :Rect2 = get_viewport_rect()
	size = rect.size

func _on_animation_finished(anim_name: String) -> void:	
	if anim_name == "show_blackout":
		MenuHandler.game_cover_finished.emit(true)
	else:
		MenuHandler.game_cover_finished.emit(false)

	if anim_name == "show_blackout" && !should_be_shown:
		hide_animation()

	if !anim_name == "show_blackout" && should_be_shown:
		show_animation()

func _on_visibillity_changed(isVisible: bool) -> void:
	should_be_shown = isVisible
	
	if anim.is_playing():
		return

	if isVisible:
		show_animation()
	else:
		hide_animation()

func is_transition_skipped() -> bool:
	var video_settings :Dictionary = DataManager.get_video_settings()
	return video_settings.skip_transitions

func show_animation() -> void:
	if is_transition_skipped():
		_on_animation_finished("show_blackout")
		return
	anim.play("show_blackout")

func hide_animation() -> void:
	if is_transition_skipped():
		_on_animation_finished("hide_blackout")
		return
	anim.play("hide_blackout")
