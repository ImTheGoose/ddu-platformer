extends Area2D

@export var jump_force :int = 1600
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = -jump_force
		anim.play("Jump")
		pass


func _on_animatable_body_2d_animation_finished() -> void:
	anim.play("Idle")
	pass # Replace with function body.
