extends MultiplayerSpawner

@export var prefab :PackedScene = preload("uid://cjjbmvmx1ilce")

func _ready() -> void:
	spawn_function = _spawn_player
	GameManager.spawn_player.connect(_on_spawn_player)
	GameManager.clear_players.connect(_on_clear_players)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_spawn_player(gpos: Vector2, peer_id: int) -> void:
	if !multiplayer.is_server():
		return

	var player_node :Player = get_node(spawn_path).get_node_or_null(str(peer_id))
	if player_node:
		print("peer: %s has changed position of player to: %s" % [peer_id, gpos])
		player_node.rpc_id(player_node.get_multiplayer_authority(), "reset_player", gpos)
	else:
		spawn([gpos, peer_id])

func _on_clear_players() -> void:
	var spawn_node :Node2D = get_node(spawn_path)
	for child in spawn_node.get_children():
		if child is Player:
			child.queue_free()

func _on_peer_disconnected(peer_id: int) -> void:
	if !multiplayer.is_server():
		return
		
	var player_node :Player = get_node(spawn_path).get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()
	

func _spawn_player(data: Array) -> Node:
	var p :Player = prefab.instantiate()
	p.name = str(data[1])
	p.assigned_peer_id = data[1]
	p.tree_entered.connect(
		func() -> void:
			p.global_position = data[0]
			)
	
	return p
	
