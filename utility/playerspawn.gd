extends Node2D

@export var parent :Node2D
@export var prefab :PackedScene

var que_pla_spawn = false

func _ready() -> void:
	GameManager.spawn_player.connect(func (): que_pla_spawn = true)

func _process(delta: float) -> void:
	if que_pla_spawn:
		que_pla_spawn = false
		_spawn_player(0)
		_spawn_player(1)
		_spawn_player(2)
		_spawn_player(3)

func _spawn_player(idx : int):
	var p: CharacterBody2D = prefab.instantiate()
	parent.add_child(p)
	p.global_position = global_position
	p.global_position.x += idx * 150
	p.player_idx = idx
