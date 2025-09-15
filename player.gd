extends CharacterBody2D

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@export var jump_strength :int = 1250
@export var speed_per_second :int = 3000
@export var max_speed :int = 450
@export var jump_buffer_time :float = 0.1
@export var wall_gravity_scale :float = 0.15

var dead = false #TEMPOARY
var double_jumped :bool = false
var air_time :float = 0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_wall_only():
			velocity.y = -jump_strength * 0.85
			if anim.flip_h:
				velocity.x = max_speed
			else:
				velocity.x = -max_speed
			
			anim.flip_h = !anim.flip_h
		
		elif is_on_floor() or air_time < jump_buffer_time:
			air_time = jump_buffer_time
			velocity.y = -jump_strength

		elif !double_jumped:
			double_jumped = true
			velocity.y = -jump_strength * 0.85
			anim.play("Double_Jump")
	
	if !is_on_floor():
		air_time += delta
	else:
		air_time = 0
	
	if is_on_floor() or is_on_wall():
		double_jumped = false
	
	var m = Input.get_axis("move_left","move_right")
	velocity.x += m * speed_per_second * delta
	
	if velocity.x > 20:
		if velocity.x > max_speed:
			velocity.x = max_speed
		if m == 0:
			velocity.x -= speed_per_second * delta
	elif velocity.x < -20:
		if velocity.x < -max_speed:
			velocity.x = -max_speed
		if m == 0:
			velocity.x += speed_per_second * delta
	else:
		velocity.x = 0


	
	if is_on_wall_only() && velocity.y > 0:
		anim.play("Wall_Jump")
		velocity += get_gravity() * delta * wall_gravity_scale
	else:
		velocity += get_gravity() * delta
	
	move_and_slide()
	
	if m > 0:
		anim.flip_h = false
	if m < 0:
		anim.flip_h = true
	_update_anim(m)


func _die(): #TEMPOARY
	dead = true
	anim.play("Die")
	

func _update_anim(m):
	if dead:
		return

	if is_on_floor():
		if m == 0:
			anim.play("Idle")
		else:
			anim.play("Run")
	elif !is_on_wall_only():
		if velocity.y < 0 && !double_jumped:
			anim.play("Jump")
		if velocity.y > 0:
			anim.play("Fall")
