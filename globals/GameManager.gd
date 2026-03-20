extends Node

signal client_start
signal client_reset
signal server_reset
signal server_start
signal spawn_level
signal on_player_death
signal game_settings_changed()
signal spawn_entity(global_position: Vector2, spawn_type: int)
signal spawn_player(global_position: Vector2, peer_id: int)
signal clear_players()
var game_paused :bool = false


var players_dead :int = 0

#region Difficulty Handling
var default_game_settings :Dictionary = {
	"difficulty" : difficulty.NORMAL,
	"gamemode" : Gamemode.GAMEMODE_STANDARD,
	"total_rounds" : 1,
	"collissions_enabled" : true,
}

var game_collissions_enabled: bool = false
var game_total_rounds: int = 1
var game_gamemode: Gamemode = Gamemode.GAMEMODE_STANDARD
var game_difficulty :difficulty = difficulty.NORMAL
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

enum Gamemode {
	GAMEMODE_STANDARD,
	GAMEMODE_CONSTANT,
}

func get_difficulty_value(key: String) -> Variant:
	var dif_settings :Dictionary = difficulty_settings[game_difficulty]
	return dif_settings[key]

func get_difficulty() -> difficulty:
	return game_difficulty

func is_collissions_enabled() -> bool:
	return game_collissions_enabled

func get_gamemode() -> Gamemode:
	return game_gamemode

func get_playing_rounds() -> int:
	return game_total_rounds

@rpc("authority","call_local","reliable")
func set_difficulty(dif: difficulty) -> void:
	game_difficulty = dif
	game_settings_changed.emit()

@rpc("authority","call_local","reliable")
func set_gamemode(gamemode: Gamemode) -> void:
	game_gamemode = gamemode
	game_settings_changed.emit()
	return

@rpc("authority","call_local","reliable")
func set_collisions_enabled(is_enabled: bool) -> void:
	game_collissions_enabled = is_enabled
	game_settings_changed.emit()
	return

@rpc("authority","call_local","reliable")
func set_playing_rounds(amount: int) -> void:
	game_total_rounds = amount
	game_settings_changed.emit()
	return

func sync_settings_to_peers() -> void:
	if multiplayer.is_server():
		rpc("set_difficulty", get_difficulty())
		rpc("set_playing_rounds", get_playing_rounds())
		rpc("set_collisions_enabled", is_collissions_enabled())
		rpc("set_gamemode", get_gamemode())

func reset_settings_to_default() -> void:
	set_difficulty(default_game_settings["difficulty"])
	set_playing_rounds(default_game_settings["total_rounds"])
	set_collisions_enabled(default_game_settings["collissions_enabled"])
	set_gamemode(default_game_settings["gamemode"])

#endregion

#region State Handling
enum STATE {
	INITIAL,
	AWAITING_RESTART,
	AWAITING_QUIT_TO_MAIN,
	AWATING_RETURN_TO_LOBBY,
	PREGAME,
	PLAYING,
	DEAD,
}

enum ClientState {
	PREGAME,
	CLIENT_ALIVE,
	CLIENT_DEAD,
}

var state :STATE = STATE.INITIAL:
	set(new_state):
		state = new_state

@rpc("authority","call_local","reliable")
func set_state(new_state : STATE) -> void:
	state = new_state

func get_state() -> STATE:
	return state
#endregion

func _ready() -> void:
	MenuHandler.game_is_covered.connect(_on_game_covered)
	multiplayer.peer_connected.connect(_on_peer_connected)
	reset_settings_to_default()

func _on_peer_connected(peer_id: int) -> void:
	sync_settings_to_peers()

func _on_game_covered() -> void:
	if state == STATE.AWAITING_QUIT_TO_MAIN:
		Lobby.close_connection()
		rpc("reset_client")
		server_reset.emit()
		Steamworks.set_rich_presense("#InMenu")
		MenuHandler.change_menu("main_menu")
		MenuHandler.hide_game()
		MenuHandler.hide_blackout()
	elif state == STATE.AWATING_RETURN_TO_LOBBY && multiplayer.is_server():
		rpc("reset_client")
		server_reset.emit()
		spawn_game()
		MenuHandler.rpc("hide_blackout")
		MenuHandler.rpc("hide_game")
		MenuHandler.rpc("change_menu", "multiplayer_lobby_menu")
		
	elif state == STATE.AWAITING_RESTART && multiplayer.is_server():
		rpc("set_difficulty", get_difficulty())
		rpc("reset_client")
		server_reset.emit()
		spawn_game()
		MenuHandler.rpc("hide_blackout")
		MenuHandler.rpc("hide_all_menus")
		MenuHandler.rpc("show_game")
		if is_game_paused():
			pause_game(false)


func pause_game(isPaused: bool) -> void:
	if multiplayer.get_peers().size() > 0:
		get_tree().paused = false
		game_paused = false
		return
	
	get_tree().paused = isPaused
	game_paused = isPaused

func is_game_paused() -> bool:
	return game_paused

func is_game_running() -> bool:
	return state == STATE.PLAYING

func restart_game() -> void:
	set_state(STATE.AWAITING_RESTART)
	MenuHandler.rpc("show_blackout")

func spawn_game() -> void:
	spawn_level.emit()
	set_state(STATE.PREGAME)


func return_to_lobby() -> void:
	if !multiplayer.is_server():
		return
	
	set_state(STATE.AWATING_RETURN_TO_LOBBY)
	MenuHandler.rpc("show_blackout")


func start_game() -> void:
	if !multiplayer.is_server():
		return
	
	rpc("start_client")
	server_start.emit()

@rpc("authority","call_local","reliable")
func start_client() -> void:
	client_start.emit()
	set_state(STATE.PLAYING)

@rpc("authority","call_local","reliable")
func reset_client() -> void:
	client_reset.emit()
	set_state(STATE.PREGAME)
	players_dead = 0

@rpc("any_peer","call_local","reliable")
func player_died() -> void:
	if !multiplayer.is_server():
		return
	
	players_dead += 1
	if players_dead < multiplayer.get_peers().size() + 1:
		return
	
	MenuHandler.rpc("change_menu", "death_menu")
	on_player_death.emit()
	rpc("set_state", STATE.DEAD)

#region QUIT Handling
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		return
		if get_state() == STATE.PREGAME or get_state() == STATE.PLAYING:
			pause_game(true)
			MenuHandler.change_menu("pause_menu")

func quit_game() -> void:
	DataManager.save_game_data()
	get_tree().quit()

func quit_to_main() -> void:
	set_state(STATE.AWAITING_QUIT_TO_MAIN)
	MenuHandler.show_blackout()

#endregion
