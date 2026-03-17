extends Area2D

@export var jump_force :int = 1600
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream :AudioStreamPlayer = $AudioStreamPlayer
@onready var boing_easteregg_file :AudioStreamMP3 = preload("uid://cuebrmqg0kvff")


func _init() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_multiplayer_authority():
			body.velocity.y = -jump_force
			StatisticManager.add_value("trampoline_jump", 1)
			rpc("show_hit")

@rpc("any_peer","call_local","reliable")
func show_hit() -> void:
	anim.play("Jump")
	
	if randf() < 0.01:
		audio_stream.stream = boing_easteregg_file
	
	audio_stream.pitch_scale = randf_range(0.9, 1.1)
	audio_stream.play()


func _on_animatable_body_2d_animation_finished() -> void:
	anim.play("Idle")
	pass # Replace with function body.
