extends Node2D

@export var camera :Camera2D

func _process(delta: float) -> void:
	global_position = camera.global_position
