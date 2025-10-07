extends Node2D

@export var parent :Node2D
@export var prefab :PackedScene

var que_pla_spawn = false

func _ready() -> void:
	GameManager.spawn_player.connect(func (): que_pla_spawn = true)

func _process(delta: float) -> void:
	if que_pla_spawn:
		que_pla_spawn = false
		_spawn_player()

func _spawn_player():
	var p: CharacterBody2D = prefab.instantiate()
	parent.add_child(p)
	p.global_position = global_position
