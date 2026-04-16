extends Entity

@export var jump_force :int = 550
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@export var boing_sounds :Dictionary[AudioStream, float] = {}
@onready var boing_easteregg_file :AudioStreamMP3 = preload("uid://cuebrmqg0kvff")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_multiplayer_authority():
			body.double_jumped = false
			body.knockback(Vector2.UP.rotated(global_rotation), jump_force)
			Stats.add_recording_value(Stats.StatType.JUMPS_TRAMPOLINE, 1)
			GameManager.add_camera_shake.emit(0.5, Vector2.UP.rotated(global_rotation), jump_force / 150)
			rpc("show_hit")

@rpc("any_peer","call_local","reliable")
func show_hit() -> void:
	anim.play("Jump")
	
	if randf() < 0.02:
		Audio.play_global(boing_easteregg_file, .8)
	else:
		Audio.play_random_pitched(boing_sounds)


func _on_animatable_body_2d_animation_finished() -> void:
	anim.play("Idle")

func _on_reset() -> void:
	anim.play("Idle")
