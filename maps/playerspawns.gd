extends Node2D

@export var spawn_pos_nodes :Array[Node2D]

func _ready() -> void:
	get_parent().ready.connect(_on_parent_ready)

func _on_parent_ready() -> void:
	if !multiplayer.is_server():
		return
	
	#if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		#if Lobby.get_lobby_size() >= spawn_idx:
			#_request_player_spawn(spawn_idx)
			#return
	
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		if not Lobby.is_lobby_local():
			_request_spawn(spawn_pos_nodes[0], 1)
			return
	
	var ids :Array[int] = Lobby.created_player_infos.keys()
	var spawn_positions :Array[Node2D] = spawn_pos_nodes.duplicate()
	spawn_positions.resize(ids.size())
	spawn_positions.shuffle()
	for i in range(ids.size()):
		_request_spawn(spawn_positions[i % 4], ids[i])
	
func _request_spawn(node: Node2D, peer_id: int) -> void:
	GameManager.spawn_player.emit(node.global_position, peer_id)
		
