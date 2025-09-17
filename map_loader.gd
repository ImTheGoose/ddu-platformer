extends Node2D

@export var map_prefab :PackedScene

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_toggle"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)

func _ready() -> void:
	_add_map()

func _add_map():
	var map = map_prefab.instantiate()
	add_child(map)
	print("Added selected map")

func _on_restart_button_pressed() -> void:
	get_child(0).queue_free()
	_add_map()
	pass # Replace with function body.


func _on_pause_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		StateManager.pause_game()
	else:
		StateManager.un_pause_game()
	
	pass # Replace with function body.
