extends Node

signal on_start_game
signal on_reset_game
signal on_stop_game
signal spawn_player
var game_state :state
var game_paused := false

enum state {
	pregame,
	running,
	dead
}

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
	return game_state == state.running

func reset_game():
	on_reset_game.emit()
	spawn_player.emit()
	game_state = state.pregame
	print("Resetting game")

func start_game():
	on_start_game.emit()
	game_state = state.running
	print("starting game")

func player_died():
	MenuManager.show_menu.emit("death_menu")
	game_state = state.dead

func quit_game():
	get_tree().quit()
