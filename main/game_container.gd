extends Node2D

func _ready() -> void:
	MenuHandler.changed_game_visibillity.connect(_on_game_visibillity_changed)

func _on_game_visibillity_changed(isVisible: bool) -> void:
	visible = isVisible
