extends GameMenu

@onready var lobby_id_label :Label = %lobby_id_label
@onready var playerlist_container :VBoxContainer = %playerlist
@onready var start_game_button:Button = %start_game_button
@onready var player_amount_label :Label = %player_amount_label
@export var player_card_prefab :PackedScene = preload("uid://cmf3dmthewfn")

func _ready() -> void:
	super()
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Lobby.lobby_ready.connect(_on_lobby_created)
	Steam.lobby_chat_update.connect(_on_steam_lobby_update)

func _on_show() -> void:
	_clear_unused_in_playerlist()

func _on_lobby_created() -> void:
	_add_player_card(multiplayer.get_unique_id())
	_update_ui_elements()

func _on_steam_lobby_update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	pass
	#if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		#_add_player_card(Lobby.get_peer_id_from_steam_id(making_change_id))
	

func _get_local_ip() -> String:
	var local_adresses := []
	for ip in IP.get_local_addresses():
		if ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("192.168."):
			local_adresses.push_back(ip)
	return local_adresses[0]

func _clear_unused_in_playerlist() -> void:
	if !multiplayer.has_multiplayer_peer():
		for child in playerlist_container.get_children():
			child.queue_free()
		return

	var peers = multiplayer.get_peers()
	for child in playerlist_container.get_children():
		if !peers.has(child.assigned_peer_id) and child.assigned_peer_id != multiplayer.get_unique_id():
			child.queue_free()

func _add_player_card(peer_id: int) -> void:
	var player_card :Node = player_card_prefab.instantiate()
	player_card.assigned_peer_id = peer_id
	playerlist_container.add_child(player_card)

func _on_peer_connected(peer_id: int) -> void:
	Alerts.push_default("Player Joined", "A player has joined the lobby.")
	_add_player_card(peer_id)
	_update_ui_elements()

func _on_peer_disconnected(id: int) -> void:
	Alerts.push_default("Player Left", "A player has left the lobby.")
	_update_ui_elements()

func _update_ui_elements() -> void:
	_clear_unused_in_playerlist()
	player_amount_label.text = "Players: %s of 4" % (multiplayer.get_peers().size() + 1)
	
	if multiplayer.is_server():
		start_game_button.visible = true
		start_game_button.disabled = multiplayer.get_peers().size() < 1
	else:
		start_game_button.visible = false
	if Lobby.is_lobby_lan():
		lobby_id_label.text = "Local IP: %s" % _get_local_ip()
	else:
		lobby_id_label.text = "Lobby ID: %s" % Lobby.STEAM_LOBBY_ID


func _on_connected_to_server() -> void:
	_add_player_card(multiplayer.get_unique_id())
	_update_ui_elements()


func _on_quit_lobby_pressed() -> void:
	Lobby.close_connection()
	MenuHandler.change_menu("main_menu")
	_clear_unused_in_playerlist()
	pass # Replace with function body.

func _on_copy_code_button_pressed() -> void:
	if Lobby.is_lobby_lan():
		DisplayServer.clipboard_set(str(_get_local_ip()))
	else:
		DisplayServer.clipboard_set(str(Lobby.STEAM_LOBBY_ID))
