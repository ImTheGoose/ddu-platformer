extends AnimatedSprite2D

class_name AnimatedEntitySprite2D

var queued_anim :String = ""


func queue_animation(_name: String):
	queued_anim = _name	

func _on_animation_looped() -> void:
	if queued_anim != "":
		play(queued_anim)
		queued_anim = ""
