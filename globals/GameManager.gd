extends Node

signal on_start_game
signal on_reset_game
signal on_stop_game
var game_running := false
var game_paused := false

func _input(event: InputEvent) -> void:
	if event.is_action("restart") && event.is_action_released("restart"):
		reset_game()

func pause_game(isPaused: bool):
	print(isPaused)
	get_tree().paused = isPaused
	game_paused = isPaused

func is_game_paused() -> bool:
	return game_paused

func is_game_running() -> bool:
	return game_running

func reset_game():
	on_reset_game.emit()
	start_game()
	print("Resetting game")

func start_game():
	on_start_game.emit()
	game_running = true
	print("starting game")

func stop_game():
	game_running = false
	on_stop_game.emit()

func quit_game():
	get_tree().quit()
