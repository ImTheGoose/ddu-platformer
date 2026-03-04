extends Node2D

func _ready() -> void:
	MenuManager.toggle_game_visibillity.connect(_on_game_visibillity_toggled)

func _on_game_visibillity_toggled(isVisible: bool) -> void:
	visible = isVisible
