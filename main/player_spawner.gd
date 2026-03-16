extends MultiplayerSpawner

@export var prefab :PackedScene = preload("uid://cjjbmvmx1ilce")

func _ready() -> void:
	spawn_function = _spawn_player
	GameManager.spawn_player.connect(_on_spawn_player)

func _on_spawn_player(gpos: Vector2, peer_id: int) -> void:
	if !multiplayer.is_server():
		return
	
	spawn([gpos, peer_id])

func _spawn_player(data: Array) -> Node:
	var p :Node2D = prefab.instantiate()
	p.tree_entered.connect(
		func(): 
			p.set_multiplayer_authority(data[1])
			p.global_position = data[0]
			)
	
	return p
	
