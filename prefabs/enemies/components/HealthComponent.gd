extends Node

class_name HealthComponent

@export var entity_node :Entity
@export var spawn_immunity_seconds :float = 0.2
var time_since_spawn :float = 0.0
signal death
var dead :bool = false

func _ready() -> void:
	entity_node.entity_reset.connect(_on_entity_reset)

func _process(delta: float) -> void:
	time_since_spawn += delta

func _on_entity_reset() -> void:
	dead = false
	time_since_spawn = 0.0

func is_immune() -> bool:
	return time_since_spawn < spawn_immunity_seconds

func is_dead() -> bool:
	return dead

@rpc("any_peer","call_local","reliable")
func die() -> void:
	if is_immune():
		return
	
	var sender :int= multiplayer.get_remote_sender_id()
	if sender == 0 or sender == multiplayer.get_unique_id():
		Stats.add_kill_to_recording(Stats.get_enemy_from_entity(entity_node.entity_type))
	
	dead = true
	death.emit()
