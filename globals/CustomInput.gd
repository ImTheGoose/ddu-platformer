extends Node

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(id: int, connected: bool) -> void:
	if connected:
		print("Controller connected")
	else:
		print("Controller disconnected")
