extends Node2D

func _ready() -> void:
	MenuHandler.changed_game_visibillity.connect(_on_game_visibillity_changed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_game_visibillity_changed(isVisible: bool) -> void:
	visible = isVisible
	
func _on_viewport_size_changed() -> void:
	var rect :Rect2 = get_viewport_rect()
	var boundary_size :Vector2 = rect.size - Vector2(1920, 1080)
	var pos_offset :Vector2 = boundary_size / 2
	position.x = -pos_offset.x
