extends Node

var STEAM_PEER : SteamMultiplayerPeer
var STEAM_LOBBY_ID : int = 0
var DEFAULT_LAN_PORT : int = 8069

signal lobby_ready()

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	Steam.lobby_created.connect(_on_steam_lobby_created)
	Steam.lobby_joined.connect(_on_steam_lobby_joined)

func _on_server_disconnected() -> void:
	print("Server host left")
	close_connection()
	MenuHandler.change_menu("main_menu")

func _on_steam_lobby_joined(lobby: int, permission: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		STEAM_LOBBY_ID = lobby
		STEAM_PEER = SteamMultiplayerPeer.new()
		STEAM_PEER.server_relay = true
		STEAM_PEER.create_client(Steam.getLobbyOwner(lobby))
		multiplayer.multiplayer_peer = STEAM_PEER
		_on_connected_to_server()
	else:
		_on_connection_failed()

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
		lobby_ready.emit()
		MenuHandler.change_menu("multiplayer_lobby_menu")

func join_lan_server(ip: String, port: int = DEFAULT_LAN_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
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
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC)

func join_steam_lobby(lobby_id: int) -> void:
	Steam.joinLobby(lobby_id)

func _on_steam_lobby_created(result: int, id: int) -> void:
	print(result, id)
	if result == Steam.Result.RESULT_OK:
		STEAM_LOBBY_ID = id
		
		STEAM_PEER = SteamMultiplayerPeer.new()
		STEAM_PEER.server_relay = true
		STEAM_PEER.create_host()
		multiplayer.multiplayer_peer = STEAM_PEER

		lobby_ready.emit()
		MenuHandler.change_menu("multiplayer_lobby_menu")

func close_connection() -> void:
	print("closing connection")
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	if STEAM_LOBBY_ID > 0:
		Steam.leaveLobby(STEAM_LOBBY_ID)
		STEAM_LOBBY_ID = 0
