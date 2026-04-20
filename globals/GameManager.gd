extends Node

signal client_start
signal client_reset
signal server_reset
signal server_start
signal clear_entities
signal prespawn_entities
signal spawn_level
signal player_death(peer_id: int)
signal game_settings_changed()
signal add_camera_shake(strenght: float, dir: Vector2, amount: float)
signal spawn_entity(global_position: Vector2, spawn_type: int, modifiers: Entity.EntityModifiers)
signal spawn_player(global_position: Vector2, peer_id: int)
signal clear_players()
var game_paused :bool = false

signal game_scores_changed()
var match_scores :Dictionary[int, int] = {}
var round_scores :Dictionary[int, float] = {}
var played_rounds :int = 0
var dead_players :Array[int] = []

#region Difficulty Handling
var default_game_settings :Dictionary = {
	"map_collection" : MapFile.CollectionType.DEFAULT,
	"difficulty" : Difficulty.Type.NORMAL,
	"gamemode" : Gamemode.GAMEMODE_STANDARD,
	"total_rounds" : 1,
	"collissions_enabled" : true,
}

var round_seconds_passed :float = 0.0
var game_is_level :bool = false
var game_collissions_enabled: bool = false
var game_total_rounds: int = 1
var game_gamemode: Gamemode = Gamemode.GAMEMODE_STANDARD
var game_map_collection: MapFile.CollectionType = MapFile.CollectionType.LEGACY

enum Gamemode {
	GAMEMODE_STANDARD,
	GAMEMODE_CONSTANT,
}

func _process(delta: float) -> void:
	if is_game_running() && not is_game_paused():
		round_seconds_passed += delta

func get_score(peer_id: int) -> float:
	return round_scores.get(peer_id, 0.0)

func get_match_score(peer_id: int) -> int:
	return match_scores.get(peer_id, 0)

func get_match_placement(peer_id: int) -> float:
	var peer_score: float = get_match_score(peer_id)
	var placement: int = 1
	for peer in match_scores.keys():
		if peer == peer_id:
			continue
		
		if match_scores[peer] > peer_score:
			placement += 1
	return placement

func get_placement(peer_id: int) -> float:
	var peer_score: float = get_score(peer_id)
	var placement: int = 1
	for peer in round_scores.keys():
		if peer == peer_id:
			continue
		if round_scores[peer] > peer_score:
			placement += 1
	return placement

@rpc("authority", "call_local", "reliable")
func set_match_score(peer_id: int, score: int) -> void:
	match_scores.set(peer_id, score)
	game_scores_changed.emit()

func sync_match_scores() -> void:
	if !multiplayer.is_server():
		return
	
	var peer_list :PackedInt32Array = multiplayer.get_peers()
	peer_list.append(multiplayer.get_unique_id())
	for peer_id: int in peer_list:
		rpc("set_match_score", peer_id, get_match_score(peer_id))

func add_winner_to_match_scores() -> void:
	if !multiplayer.is_server():
		return
	
	for peer_id: int in round_scores.keys():
		if get_placement(peer_id) == 1 && round_scores.get(peer_id) != 0:
			rpc("set_match_score", peer_id, get_match_score(peer_id) + 1)
	round_scores.clear()

@rpc("any_peer","call_local","reliable")
func set_round_score(peer_id: int, score: float) -> void:
	round_scores.set(peer_id, score)
	game_scores_changed.emit()

func get_map_collection() -> MapFile.CollectionType:
	return game_map_collection

func is_collissions_enabled() -> bool:
	return game_collissions_enabled

func get_gamemode() -> Gamemode:
	return game_gamemode

func get_total_rounds() -> int:
	return game_total_rounds

@rpc("authority","call_local","reliable")
func set_map_collection(collection: MapFile.CollectionType) -> void:
	game_map_collection = collection
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
func set_total_rounds(amount: int) -> void:
	game_total_rounds = amount
	game_settings_changed.emit()
	return
	
@rpc("authority","call_local","reliable")
func set_rounds_played(amount_played: int, show_alert: bool = false) -> void:
	played_rounds = amount_played
	if show_alert && multiplayer.multiplayer_peer is not OfflineMultiplayerPeer:
		Alerts.push_default("Next Round", "Round %s out of %s" % [played_rounds, game_total_rounds])

func next_round() -> void:
	if game_total_rounds > played_rounds:
		rpc("set_rounds_played", played_rounds + 1, true)
		add_winner_to_match_scores()
		
		restart_game()
	elif multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		rpc("set_rounds_played", 0)
		restart_game()
	else:
		return_to_lobby()


func sync_settings_to_peers() -> void:
	if multiplayer.is_server():
		rpc("set_map_collection", get_map_collection())
		Difficulty.rpc("set_difficulty", Difficulty.get_difficulty())
		rpc("set_total_rounds", get_total_rounds())
		rpc("set_collisions_enabled", is_collissions_enabled())
		rpc("set_gamemode", get_gamemode())

func reset_settings_to_default() -> void:
	set_map_collection(default_game_settings["map_collection"])
	Difficulty.set_difficulty(default_game_settings["difficulty"])
	set_total_rounds(default_game_settings["total_rounds"])
	set_collisions_enabled(default_game_settings["collissions_enabled"])
	set_gamemode(default_game_settings["gamemode"])

#endregion

#region State Handling
enum STATE {
	INITIAL,
	AWAITING_RESTART,
	AWAITING_QUIT_TO_MAIN,
	AWATING_RETURN_TO_LOBBY,
	AWAITING_GAME_CONCLUSION,
	PREGAME,
	PLAYING,
	DEAD,
	POST_GAME,
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
	Difficulty.difficulty_changed.connect(_on_difficulty_changed)
	process_mode = Node.PROCESS_MODE_ALWAYS
	MenuHandler.game_is_covered.connect(_on_game_covered)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	reset_settings_to_default()

func _on_difficulty_changed() -> void:
	game_settings_changed.emit()

func _on_peer_connected(peer_id: int) -> void:
	sync_settings_to_peers()

func _on_peer_disconnected(peer_id: int) -> void:
	dead_players.erase(peer_id)
	match_scores.erase(peer_id)
	

func _on_game_covered() -> void:
	if state == STATE.AWAITING_QUIT_TO_MAIN:
		Lobby.close_connection()
		rpc("clear_game")
		rpc("set_rounds_played", 0)
		rpc("reset_client")
		server_reset.emit()
		Steamworks.set_rich_presense("#InMenu")
		MenuHandler.change_menu("main_menu")
		MenuHandler.hide_game()
		MenuHandler.hide_blackout()
	
	elif state == STATE.AWAITING_GAME_CONCLUSION && multiplayer.is_server():
		add_winner_to_match_scores()
		sync_match_scores()
		MenuHandler.rpc("hide_blackout")
		MenuHandler.rpc("hide_game")
		MenuHandler.rpc("change_menu", "multiplayer_win_menu")

	elif state == STATE.AWATING_RETURN_TO_LOBBY && multiplayer.is_server():
		rpc("clear_game")
		rpc("reset_client")
		rpc("set_rounds_played", 0)
		server_reset.emit()
		MenuHandler.rpc("hide_blackout")
		MenuHandler.rpc("hide_game")
		if Lobby.is_lobby_local():
			MenuHandler.rpc("change_menu", "local_lobby_menu")
		else:
			MenuHandler.rpc("change_menu", "multiplayer_lobby_menu")
		
	elif state == STATE.AWAITING_RESTART && multiplayer.is_server():
		rpc("reset_client")
		server_reset.emit()
		rpc("spawn_game")
		MenuHandler.rpc("hide_blackout")
		MenuHandler.rpc("hide_all_menus")
		MenuHandler.rpc("show_game")
		if is_game_paused():
			pause_game(false)

func pause_game(isPaused: bool) -> void:
	if multiplayer.multiplayer_peer is not OfflineMultiplayerPeer:
		get_tree().paused = false
		game_paused = false
		return
	
	get_tree().paused = isPaused
	game_paused = isPaused

func is_game_paused() -> bool:
	return game_paused

func is_game_running() -> bool:
	if state == STATE.PLAYING or state == STATE.DEAD:
		return true
	else:
		return false

func is_alive() -> bool:
	return state != STATE.DEAD

func restart_game() -> void:
	set_state(STATE.AWAITING_RESTART)
	MenuHandler.rpc("show_blackout")

@rpc("authority","call_local","reliable")
func spawn_game() -> void:
	round_seconds_passed = 0.0
	Maps.mount_level(Levels.get_level_index())
	spawn_level.emit()
	set_state(STATE.PREGAME)


func return_to_lobby() -> void:
	if !multiplayer.is_server():
		return
	
	set_state(STATE.AWATING_RETURN_TO_LOBBY)
	MenuHandler.rpc("show_blackout")

@rpc("authority","call_local","reliable")
func clear_game() -> void:
	clear_entities.emit()
	clear_players.emit()

@rpc("authority", "call_local", "reliable")
func replay_game() -> void:
	if multiplayer.is_server():
		MenuHandler.rpc("show_blackout")
		rpc("set_rounds_played", 0)
		match_scores.clear()
		next_round()
		

@rpc("authority","call_local","reliable")
func prepare_game(is_level: bool = false) -> void:
	game_is_level = is_level
	
	clear_game()
	prespawn_entities.emit()
	
	if multiplayer.is_server():
		Maps.refresh_map_pools()
		Maps.mount_level(Levels.get_level_index())
		MenuHandler.rpc("show_blackout")
		rpc("set_rounds_played", 0)
		match_scores.clear()
		sync_match_scores()
		next_round()

func is_playing_level() -> bool:
	return game_is_level

func is_playing_singleplayer() -> bool:
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		if not Lobby.is_lobby_local():
			return true
	
	return false

@rpc("any_peer","call_local","reliable")
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
	dead_players.clear()
	round_scores.clear()
	pause_game(false)

@rpc("any_peer","call_local","reliable")
func player_died(peer_id: int, time_at_death: float = 0.0) -> void:
	player_death.emit(peer_id)
	
	if not Lobby.is_lobby_local():
		if multiplayer.get_unique_id() == peer_id:
			if get_state() != STATE.POST_GAME:
				set_state(STATE.DEAD)
	
	if !multiplayer.is_server():
		return
	
	if time_at_death == 0.0:
		rpc("set_round_score", peer_id, round_seconds_passed)
	else:
		rpc("set_round_score", peer_id, time_at_death)
	
	dead_players.append(peer_id)
	if dead_players.size() < Lobby.get_lobby_size() - 1:
		return
	
	for id:int in Lobby.created_player_infos.keys():
		if not dead_players.has(id):
			rpc("set_round_score", id, 999999)
	
	rpc("set_state", STATE.POST_GAME)
	
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer && not Lobby.is_lobby_local():
		MenuHandler.rpc("change_menu", "death_menu")
	elif get_total_rounds() > played_rounds:
		MenuHandler.rpc("change_menu", "multiplayer_round_win_menu")
	else:
		MenuHandler.rpc("show_blackout")
		set_state(STATE.AWAITING_GAME_CONCLUSION)



#region QUIT Handling
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if get_state() == STATE.PREGAME or get_state() == STATE.PLAYING:
			if multiplayer.multiplayer_peer is OfflineMultiplayerPeer && !is_game_paused() && MenuHandler.is_game_visible():
				pause_game(true)
				MenuHandler.change_menu("pause_menu")

func quit_game() -> void:
	Steamworks.store_steam_data(true)
	DataManager.save_game_data()
	get_tree().quit()

func quit_to_main() -> void:
	set_state(STATE.AWAITING_QUIT_TO_MAIN)
	MenuHandler.show_blackout()

func _input(event: InputEvent) -> void:
	if !event.is_pressed():
		return
	
	if event.is_action("pause_game"):
		if !MenuHandler.is_game_visible():
			return
		
		if GameManager.get_state() == GameManager.STATE.POST_GAME:
			return
		
		if GameManager.is_game_paused() or MenuHandler.is_menu_visible("pause_menu"):
			GameManager.pause_game(false)
			MenuHandler.hide_all_menus()
		else:
			GameManager.pause_game(true)
			MenuHandler.change_menu("pause_menu")

	if event.is_action("fullscreen_toggle"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DataManager.save_video_setting("fullscreen", is_window)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
#endregion
