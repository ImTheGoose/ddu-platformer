extends Area2D

class_name HitArea

@export var kill_type :StatisticManager.death_type = StatisticManager.death_type.spike
@onready var position_node :Node2D = get_child(0)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		StatisticManager.set_value("death_type", kill_type)
		body.hit(position_node.global_position.direction_to(body.global_position))
		pass
