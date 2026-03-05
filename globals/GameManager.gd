extends Node

signal on_start_game
signal on_reset_game
signal on_player_death
signal spawn_player
var game_paused :bool = false
var game_difficulty :difficulty = difficulty.NORMAL

var players_dead :int = 0

var difficulty_settings :Dictionary = {
	difficulty.VERY_EASY : {
		"camera_speed" : 0.4,
		"enemy_spawn_rate": 0.15,
		"collectable_spawn_rate": 0.15,
	},difficulty.EASY : {
		"camera_speed" : 0.8,
		"enemy_spawn_rate": 0.70,
		"collectable_spawn_rate": 0.7,
	},difficulty.NORMAL : {
		"camera_speed" : 1,
		"enemy_spawn_rate": 0.85,
		"collectable_spawn_rate": 1.0,
	},difficulty.HARD : {
		"camera_speed" : 1.1,
		"enemy_spawn_rate": 1.0,
		"collectable_spawn_rate": 1.0,
	},difficulty.IMPOSSIBLE : {
		"camera_speed" : 1.3,
		"enemy_spawn_rate": 1.0,
		"collectable_spawn_rate": 1.0,
	},
}

enum difficulty {
	VERY_EASY,
	EASY,
	NORMAL,
	HARD,
	IMPOSSIBLE
}

enum STATE {
	INITIAL,
	AWAITING_RESTART,
	AWAITING_QUIT_TO_MAIN,
	PREGAME,
	PLAYING,
	DEAD,
}

func _ready() -> void:
	MenuHandler.game_is_covered.connect(_on_game_covered)

func _on_game_covered() -> void:
	if state == STATE.AWAITING_RESTART:
		force_reset_game()
		MenuHandler.hide_blackout()
		MenuHandler.hide_all_menus()
		MenuHandler.show_game()
		if is_game_paused():
			pause_game(false)
	elif state == STATE.AWAITING_QUIT_TO_MAIN:
		MenuHandler.change_menu("main_menu")
		MenuHandler.hide_game()
		MenuHandler.hide_blackout()

var state :STATE = STATE.INITIAL:
	set(new_state):
		state = new_state

func set_state(new_state : STATE) -> void:
	state = new_state

func get_state() -> STATE:
	return state

func get_difficulty_value(key: String) -> Variant:
	var dif_settings :Dictionary = difficulty_settings[game_difficulty]
	return dif_settings[key]

func get_difficulty() -> difficulty:
	return game_difficulty

func set_difficulty(dif: difficulty) -> void:
	game_difficulty = dif

func pause_game(isPaused: bool) -> void:
	get_tree().paused = isPaused
	game_paused = isPaused

func is_game_paused() -> bool:
	return game_paused

func is_game_running() -> bool:
	return state == STATE.PLAYING

func reset_game() -> void:
	set_state(STATE.AWAITING_RESTART)
	MenuHandler.show_blackout()

func force_reset_game() -> void:
	on_reset_game.emit()
	spawn_player.emit()
	set_state(STATE.PREGAME)
	players_dead = 0

func quit_to_main() -> void:
	set_state(STATE.AWAITING_QUIT_TO_MAIN)
	MenuHandler.show_blackout()

func start_game() -> void:
	on_start_game.emit()
	set_state(STATE.PLAYING)

func player_died() -> void:
	players_dead += 1
	if players_dead < 1:
		return
	
	MenuHandler.show_menu("death_menu")
	on_player_death.emit()
	set_state(STATE.DEAD)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()

func quit_game() -> void:
	DataManager.save_game_data()
	get_tree().quit()
