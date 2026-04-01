extends Node

class_name HealthComponent

@export var entity_node :Entity

func _ready() -> void:
	entity_node.entity_reset.connect(_on_entity_reset)

func _on_entity_reset() -> void:
	dead = false

signal death
var dead :bool = false

func is_dead() -> bool:
	return dead

@rpc("any_peer","call_local","reliable")
func die() -> void:
	dead = true
	death.emit()
