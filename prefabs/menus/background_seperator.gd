extends ColorRect

func _ready() -> void:
	MenuManager.toggle_background_seperator.connect(_toggle_visible)

func _toggle_visible(isVisible):
	visible = isVisible
	
