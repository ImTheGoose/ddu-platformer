extends Node

var STEAM_PEER : SteamMultiplayerPeer
var STEAM_LOBBY_ID : int = 0
var DEFAULT_LAN_PORT : int = 8069

var created_player_infos :Dictionary[int, PlayerInfo] = {}

signal lobby_ready()

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	Steam.join_requested.connect(_on_join_requested)
	Steam.lobby_created.connect(_on_steam_lobby_created)
	Steam.lobby_joined.connect(_on_steam_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)

func _on_server_disconnected() -> void:
	print("Server host left")
	close_connection()
	MenuHandler.change_menu("main_menu")

func _on_join_requested(lobby_id: int, steam_id: int) -> void:
	Lobby.join_steam_lobby(lobby_id)

func _on_steam_lobby_joined(lobby: int, permission: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if multiplayer.is_server():
			return
		STEAM_LOBBY_ID = lobby
		STEAM_PEER = SteamMultiplayerPeer.new()
		STEAM_PEER.server_relay = true
		STEAM_PEER.create_client(Steam.getLobbyOwner(lobby))
		multiplayer.multiplayer_peer = STEAM_PEER
		_on_connected_to_server()
	else:
		_on_connection_failed()

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

func _on_connected_to_server() -> void:
	print("Successfully connected to server")
	MenuHandler.change_menu("multiplayer_lobby_menu")

func _on_connection_failed() -> void:
	print("Failed to establish connection to server")

func create_lan_server(port: int = DEFAULT_LAN_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 4)
	multiplayer.multiplayer_peer = peer
	if err != OK:
		print("Error occured while creating lan lobby")
		close_connection()
	else:
		add_player_info(multiplayer.multiplayer_peer.get_unique_id())
		lobby_ready.emit()
		MenuHandler.change_menu("multiplayer_lobby_menu")

func join_lan_server(ip: String, port: int = DEFAULT_LAN_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	add_player_info(multiplayer.multiplayer_peer.get_unique_id())
	if err != OK:
		print("Error occured while joining lan server")
		close_connection()
		return

func is_lobby_lan() -> bool:	
	if multiplayer.multiplayer_peer is SteamMultiplayerPeer:
		return false
	else:
		return true

func create_steam_lobby() -> void:
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 4)

func join_steam_lobby(lobby_id: int) -> void:
	Steam.joinLobby(lobby_id)

func kick_peer(peer_id: int) -> void:
	multiplayer.multiplayer_peer.disconnect_peer(peer_id)

func _on_peer_connected(peer_id: int) -> void:
	add_player_info(peer_id)

func _on_steam_lobby_created(result: int, id: int) -> void:
	print(result, id)
	if result == Steam.Result.RESULT_OK:
		STEAM_LOBBY_ID = id
		
		STEAM_PEER = SteamMultiplayerPeer.new()
		STEAM_PEER.server_relay = true
		STEAM_PEER.create_host()
		multiplayer.multiplayer_peer = STEAM_PEER
		add_player_info(multiplayer.multiplayer_peer.get_unique_id())

		lobby_ready.emit()
		MenuHandler.change_menu("multiplayer_lobby_menu")

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

func get_player_info(peer_id: int) -> PlayerInfo:
	return created_player_infos[peer_id]

func clear_unused_player_info() -> void:
	var peers := multiplayer.get_peers()
	for key in created_player_infos:
		if !peers.has(key):
			created_player_infos.erase(key)

func close_connection() -> void:
	print("closing connection")
	created_player_infos.clear()
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	if STEAM_LOBBY_ID > 0:
		Steam.leaveLobby(STEAM_LOBBY_ID)
		STEAM_LOBBY_ID = 0
