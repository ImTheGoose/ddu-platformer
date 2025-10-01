extends Area2D

@onready var col = get_child(0)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var dir = global_position.direction_to(body.global_position)
		
		if dir.y <= -0.65:
			body.velocity.y = -800
			set_deferred("monitoring", false)
			get_parent().die()
		else:
			body.hit(col.global_position.direction_to(body.global_position))
		pass
