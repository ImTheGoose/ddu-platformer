extends Area2D

class_name HitArea

@onready var col = get_child(0)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit(col.global_position.direction_to(body.global_position))
		pass
