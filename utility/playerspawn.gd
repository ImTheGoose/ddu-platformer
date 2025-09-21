extends Node2D

@export var parent :Node2D
@export var prefab :PackedScene

func _ready() -> void:
	GameManager.spawn_player.connect(_spawn_player)


func _spawn_player():
	var p: CharacterBody2D = prefab.instantiate()
	parent.add_child(p)
	p.global_position = global_position
