extends Area2D

@export var jump_force :int = 1600
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream :AudioStreamPlayer = $AudioStreamPlayer
@onready var boing_easteregg_file = preload("res://assets/audio/sfx/boing_easteregg.mp3")


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = -jump_force
		anim.play("Jump")
		
		if randf() < 0.01:
			audio_stream.stream = boing_easteregg_file
		
		audio_stream.pitch_scale = randf_range(0.9, 1.1)
		audio_stream.play()
		StatisticManager.add_value("trampoline_jump", 1)
		pass


func _on_animatable_body_2d_animation_finished() -> void:
	anim.play("Idle")
	pass # Replace with function body.
