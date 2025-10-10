extends Node

signal on_start_game
signal on_reset_game
signal on_player_death
signal spawn_player
var game_state :state
var game_paused := false
var game_difficulty :difficulty = difficulty.normal

var difficulty_settings = {
	difficulty.very_easy : {
		"camera_speed" : 0.4,
		"enemy_spawn_rate": 0.15,
		"collectable_spawn_rate": 0.15,
	},difficulty.easy : {
		"camera_speed" : 0.8,
		"enemy_spawn_rate": 0.70,
		"collectable_spawn_rate": 0.7,
	},difficulty.normal : {
		"camera_speed" : 1,
		"enemy_spawn_rate": 0.85,
		"collectable_spawn_rate": 1.0,
	},difficulty.hard : {
		"camera_speed" : 1.1,
		"enemy_spawn_rate": 1.0,
		"collectable_spawn_rate": 1.0,
	},difficulty.impossible : {
		"camera_speed" : 1.3,
		"enemy_spawn_rate": 1.0,
		"collectable_spawn_rate": 1.0,
	},
}

enum difficulty {
	very_easy,
	easy,
	normal,
	hard,
	impossible
}

enum state {
	pregame,
	running,
	dead
}

func get_difficulty_value(key: String):
	var dif_settings = difficulty_settings[game_difficulty]
	return dif_settings[key]

func get_difficulty():
	return game_difficulty

func set_difficulty(dif: difficulty):
	game_difficulty = dif

func pause_game(isPaused: bool):
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
	on_player_death.emit()
	game_state = state.dead

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()

func quit_game():
	DataManager.save_game_data()
	get_tree().quit()
