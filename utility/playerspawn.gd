extends Node2D

@export var parent :Node2D
@export var prefab :PackedScene

var que_pla_spawn :bool = false

func _ready() -> void:
	GameManager.spawn_player.connect(func () -> void: que_pla_spawn = true)

func _process(delta: float) -> void:
	if que_pla_spawn:
		que_pla_spawn = false
		spawn_peers()

func spawn_peers() -> void:
	_spawn_player()
	var offset :int = 0
	for peer in multiplayer.get_peers():
		var p = prefab.instantiate()
		p.name = str(peer)
		parent.add_child(p)
		p.global_position = global_position
		p.global_position.x += offset
		offset += 50
	
	return

func _spawn_player() -> void:
	var p = prefab.instantiate()
	p.name = str(1)

	parent.add_child(p)
	p.global_position = global_position
