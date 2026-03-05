extends ColorRect

func _ready() -> void:
	MenuHandler.changed_seperator_visibillity.connect(_toggle_visible)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	var rect :Rect2 = get_viewport_rect()
	size = rect.size
	var boundary_size :Vector2 = rect.size - Vector2(1920, 1080)
	var pos_offset :Vector2 = boundary_size / 2
	position.x = -pos_offset.x

func _toggle_visible(isVisible: bool) -> void:
	visible = isVisible
