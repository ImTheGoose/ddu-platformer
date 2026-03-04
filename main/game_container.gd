extends Node2D

func _ready() -> void:
	MenuManager.toggle_game_visibillity.connect(_toggle_visible)

func _toggle_visible(isVisible):
	visible = isVisible
