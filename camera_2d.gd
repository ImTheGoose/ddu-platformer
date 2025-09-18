extends Camera2D

var speed = 1200

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position.y -= speed * delta
	else:
		position.y -= speed / 20 * delta
