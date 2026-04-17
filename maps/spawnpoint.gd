extends Node2D

@export var spawn_idx :int = 1

func _ready() -> void:
	get_parent().ready.connect(_on_parent_ready)

func _on_parent_ready() -> void:
	if !multiplayer.is_server():
		return
	
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		if Lobby.get_lobby_size() >= spawn_idx:
			_request_player_spawn(spawn_idx)
			return

	if Lobby.get_lobby_size() < spawn_idx:
		return

	var peers :PackedInt32Array = multiplayer.get_peers()
	
	_request_player_spawn(peers[spawn_idx - 2])
	
func _request_player_spawn(peer_id: int) -> void:
	GameManager.spawn_player.emit(global_position, peer_id)
		
