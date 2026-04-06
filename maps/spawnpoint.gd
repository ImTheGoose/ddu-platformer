extends Node2D

@export var spawn_idx :int = 1

func _ready() -> void:
	get_parent().ready.connect(_on_parent_ready)

func _on_parent_ready() -> void:
	if !multiplayer.is_server():
		return
	
	if spawn_idx == 1:
		_request_player_spawn(1)
		return

	var peers :PackedInt32Array = multiplayer.get_peers()
	
	if peers.size() < spawn_idx - 1:
		return
	
	_request_player_spawn(peers[spawn_idx - 2])
	
func _request_player_spawn(peer_id: int) -> void:
	GameManager.spawn_player.emit(global_position, peer_id)
		
