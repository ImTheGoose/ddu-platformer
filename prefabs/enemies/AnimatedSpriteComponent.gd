extends AnimatedSprite2D

class_name AnimatedSpriteComponent

var target_rot :float = 0.0
var start_vel :Vector2 = Vector2.ZERO

func _process(delta: float) -> void:	
	if target_rot == 0:
		return

	start_vel.y += 1100 * delta
	global_position += start_vel * delta
	rotation = lerp_angle(rotation, target_rot, delta)

func death() -> void:
	target_rot = randf_range(-35, 35)
	start_vel = Vector2(randf_range(-150, 150), randf_range(-100, -600))

var queued_anim :String = ""


func queue_animation(_name: String) -> void:
	queued_anim = _name	

func _on_animation_looped() -> void:
	if queued_anim != "":
		play(queued_anim)
		queued_anim = ""
