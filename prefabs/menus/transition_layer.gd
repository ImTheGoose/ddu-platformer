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
	var boundary_size :Vector2 = rect.size - Vector2(1920, 1080)
	var pos_offset :Vector2 = boundary_size / 2
	position.x = -pos_offset.x

func _on_animation_finished(anim_name: String) -> void:	
	if anim_name == "show_blackout":
		MenuHandler.game_is_covered.emit()

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


func show_animation() -> void:
	anim.play("show_blackout")

func hide_animation() -> void:
	anim.play("hide_blackout")
