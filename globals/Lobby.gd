extends Node

var STEAM_PEER : SteamMultiplayerPeer
var STEAM_LOBBY_ID : int = 0
var DEFAULT_LAN_PORT : int = 8069

var created_player_infos :Dictionary[int, PlayerInfo] = {}

signal lobby_ready()
signal connection_error(error_reason: String)
signal peer_linked_to_steam(peer_id: int, steam_id: int)
signal peer_cosmetic_updated(peer_id: int, data_type:DataRequestType, cosmetic_data: Array[Variant])

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Steam.join_requested.connect(_on_steam_join_requested)
	Steam.lobby_created.connect(_on_steam_lobby_created)
	Steam.lobby_joined.connect(_on_steam_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	close_connection()

#region Lobby RPC commands

@rpc("any_peer","call_local","reliable")
func handle_data_from_peer(data_type: DataRequestType, data: Array[Variant]) -> void:
	var peer_id :int = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = multiplayer.get_unique_id()
	match data_type:
		DataRequestType.STEAM_ID:
			if created_player_infos.has(peer_id):
				peer_linked_to_steam.emit(peer_id, data[0])
			else:
				print("Retrived steam id from a peer, that doesnt have a linked info. Peer is: ", peer_id)
		
		DataRequestType.COSMETIC_SKIN, DataRequestType.COSMETIC_OUTLINE:
			peer_cosmetic_updated.emit(peer_id, data_type, data)


@rpc("any_peer","call_local","reliable")
func transmit_data_to_sender(data_type: DataRequestType) -> void:
	var sender_peer_id :int = multiplayer.get_remote_sender_id()
	var data :Array[Variant] = []
	var peer_id :int = multiplayer.get_unique_id()
	match data_type:
		DataRequestType.STEAM_ID:
			var steam_id :int = Steam.getSteamID()
			data = [steam_id]
		
		DataRequestType.COSMETIC_OUTLINE:
			var outline_hex :String = DataManager.get_value("selected_outline_hex")
			data = [outline_hex]
			
		DataRequestType.COSMETIC_SKIN:
			var skin_name :String = DataManager.get_value("selected_skin")
			data = [skin_name]
	
	if sender_peer_id == 0:
		rpc("handle_data_from_peer", data_type, data)
	else:
		rpc_id(sender_peer_id, "handle_data_from_peer", data_type, data)

func transmit_data_to_lobby(data_type: DataRequestType) -> void:
	transmit_data_to_sender(data_type)
	

func request_data_from_peer(peer_id: int, data_type: DataRequestType) -> void:
	rpc_id(peer_id, "transmit_data_to_sender", data_type)

enum DataRequestType {
	COSMETIC_OUTLINE,
	COSMETIC_SKIN,
	STEAM_ID,
}

#endregion

#region Lan Lobby Hadling

func _on_server_disconnected() -> void:
	Alerts.push_error("Disconnected", "The lobby host has left.")
	close_connection()
	MenuHandler.change_menu("main_menu")
	GameManager.reset_client()
	MenuHandler.hide_game()

func _on_connected_to_server() -> void:
	MenuHandler.change_menu("multiplayer_lobby_menu")
	add_player_info(multiplayer.get_unique_id())

func _on_connection_failed() -> void:
	Lobby.connection_error.emit("Failed to establish connection to server")

func create_lan_server(port: int = DEFAULT_LAN_PORT) -> void:
	MenuHandler.change_menu("multiplayer_status_menu")
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 3)
	multiplayer.multiplayer_peer = peer
	if err != OK:
		connection_error.emit("Error occured while creating lan lobby")
		close_connection()
		return

	add_player_info(multiplayer.multiplayer_peer.get_unique_id())
	lobby_ready.emit()
	MenuHandler.change_menu("multiplayer_lobby_menu")
	Alerts.push_success("Lobby Created", "Lobby was successfully created.")

func join_lan_server(ip: String, port: int = DEFAULT_LAN_PORT) -> void:
	MenuHandler.change_menu("multiplayer_status_menu")
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	if err != OK:
		connection_error.emit("Failed to connect to lan server.")
		close_connection()
		return

#endregion

#region Steam Lobby Handling

func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	# Get the user who has made the lobby change
	var changer_name: String = Steam.getFriendPersonaName(change_id)

	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		print("%s has joined the lobby." % changer_name)

	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		print("%s has left the lobby." % changer_name)

	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		print("%s has been kicked from the lobby." % changer_name)

	# Else if a player has been banned
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		print("%s has been banned from the lobby." % changer_name)

	# Else there was some unknown change
	else:
		print("%s did... something." % changer_name)

func _on_steam_join_requested(lobby_id: int, steam_id: int) -> void:
	Lobby.join_steam_lobby(lobby_id)

func create_steam_lobby() -> void:
	MenuHandler.change_menu("multiplayer_status_menu")
	if Steam.loggedOn():
		Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 4)
	else:
		Lobby.connection_error.emit("No connection to steam servers.")
		
func _on_steam_lobby_created(result: int, id: int) -> void:
	if result == Steam.Result.RESULT_OK:
		STEAM_LOBBY_ID = id
		
		STEAM_PEER = SteamMultiplayerPeer.new()
		STEAM_PEER.server_relay = true
		STEAM_PEER.create_host()
		multiplayer.multiplayer_peer = STEAM_PEER
		add_player_info(multiplayer.multiplayer_peer.get_unique_id())

		lobby_ready.emit()
		MenuHandler.change_menu("multiplayer_lobby_menu")
		Alerts.push_success("Lobby Created", "Lobby was successfully created.")
	else:
		Lobby.connection_error.emit("Failed to create online lobby. Please try again.")

func join_steam_lobby(lobby_id: int) -> void:
	MenuHandler.change_menu("multiplayer_status_menu")
	if Steam.loggedOn():
		Steam.joinLobby(lobby_id)
	else:
		Lobby.connection_error.emit("No connection to steam servers.")

func _on_steam_lobby_joined(lobby: int, permission: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if multiplayer.is_server() && multiplayer.multiplayer_peer is not OfflineMultiplayerPeer:
			return
		STEAM_LOBBY_ID = lobby
		STEAM_PEER = SteamMultiplayerPeer.new()
		STEAM_PEER.server_relay = true
		STEAM_PEER.create_client(Steam.getLobbyOwner(lobby))
		multiplayer.multiplayer_peer = STEAM_PEER
	else:
		_on_connection_failed()

#endregion

#region Lobby helper functions

func is_lobby_lan() -> bool:	
	if multiplayer.multiplayer_peer is SteamMultiplayerPeer:
		return false
	else:
		return true

func kick_peer(peer_id: int) -> void:
	multiplayer.multiplayer_peer.disconnect_peer(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	Steamworks.set_rich_presense("lobby_count", str(multiplayer.get_peers().size()+1))
	if multiplayer.get_peers().size() == 0 && multiplayer.is_server() && !MenuHandler.is_menu_visible("multiplayer_lobby_menu"):
		GameManager.return_to_lobby()
		Alerts.push_default("Empty Lobby", "Returning to lobby menu.")
	
func _on_peer_connected(peer_id: int) -> void:
	Steamworks.set_rich_presense("lobby_count", str(multiplayer.get_peers().size()+1))
	add_player_info(peer_id)

func get_peer_id_from_steam_id(steam_id: int) -> int:
	if multiplayer.multiplayer_peer is SteamMultiplayerPeer:
		return multiplayer.multiplayer_peer.get_peer_id_for_steam_id(steam_id)
	return steam_id

func get_steam_id_from_peer_id(peer_id: int) -> int:
	if multiplayer.multiplayer_peer is SteamMultiplayerPeer:
		return multiplayer.multiplayer_peer.get_steam_id_for_peer_id(peer_id)
	return peer_id

func add_player_info(peer_id: int) -> void:
	created_player_infos.set(peer_id, PlayerInfo.new(peer_id))
	
	request_data_from_peer(peer_id, DataRequestType.STEAM_ID)

func get_player_info(peer_id: int) -> PlayerInfo:
	return created_player_infos[peer_id]

func clear_unused_player_info() -> void:
	var peers := multiplayer.get_peers()
	for key in created_player_infos:
		if !peers.has(key):
			created_player_infos.erase(key)

func lock_lobby() -> void:
	if multiplayer.is_server():
		multiplayer.multiplayer_peer.refuse_new_connections = true
		if STEAM_LOBBY_ID > 0:
			Steam.setLobbyJoinable(STEAM_LOBBY_ID, false)

func unlock_lobby() -> void:
	if multiplayer.is_server():
		multiplayer.multiplayer_peer.refuse_new_connections = false
		if STEAM_LOBBY_ID > 0:
			Steam.setLobbyJoinable(STEAM_LOBBY_ID, true)

func close_connection() -> void:
	Steamworks.set_rich_presense("#InMenu")
	created_player_infos.clear()
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	add_player_info(multiplayer.get_unique_id())
	if STEAM_LOBBY_ID > 0:
		Steam.leaveLobby(STEAM_LOBBY_ID)
		STEAM_LOBBY_ID = 0
	GameManager.set_state(GameManager.STATE.INITIAL)
	GameManager.clear_players.emit()
	GameManager.server_reset.emit()
	GameManager.client_reset.emit()
	GameManager.reset_settings_to_default()

#endregion
