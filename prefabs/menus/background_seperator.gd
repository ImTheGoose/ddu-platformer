extends ColorRect

func _ready() -> void:
	MenuHandler.changed_seperator_visibillity.connect(_toggle_visible)

func _toggle_visible(isVisible: bool) -> void:
	visible = isVisible
