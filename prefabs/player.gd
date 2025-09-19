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
	if dead:
		var col = $CollisionShape2D
		col.disabled = true
		_limit_horizontal_velocity(max_speed * 4)
		_reduce_horizontal_velocity(delta, speed_per_second / 20)
		_apply_gravity(delta, 0.65)
		move_and_slide()
		return
	
	var m = Input.get_axis("move_left","move_right")
	_limit_horizontal_velocity(max_speed)
	if m == 0:
		_reduce_horizontal_velocity(delta, speed_per_second)
	
	if Input.is_action_just_pressed("jump"):
		_attempt_jump()
	
	if is_on_floor() or is_on_wall():
		air_time = 0
	else:
		air_time += delta

	
	if is_on_floor() or is_on_wall():
		double_jumped = false
	
	velocity.x += m * speed_per_second * delta
	


	if is_on_wall_only() && velocity.y > 0:
		anim.play("Wall_Jump")
		_apply_gravity(delta, wall_gravity_scale)
	else:
		_apply_gravity(delta)
	

	move_and_slide()
	
	if m > 0:
		anim.flip_h = false
	if m < 0:
		anim.flip_h = true
	_update_anim(m)

func _attempt_jump():
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

func _apply_gravity(delta: float, gravity_scale: float = 1):
	velocity += get_gravity() * delta * gravity_scale
	

func _limit_horizontal_velocity(max_vel: int):
	if velocity.x > 20:
		if velocity.x > max_vel:
			velocity.x = max_vel
	elif velocity.x < -20:
		if velocity.x < -max_vel:
			velocity.x = -max_vel
	else:
		velocity.x = 0

func _reduce_horizontal_velocity(delta: float, amount_per_second: int):
	if velocity.x < -20:
		velocity.x += amount_per_second * delta
	elif velocity.x > 20:
		velocity.x -= amount_per_second * delta


func _die(): #TEMPOARY
	print("player dying")
	dead = true
	GameManager.player_died()
	anim.play("Die")

func hit(vec: Vector2):
	velocity = vec * max_speed * 1.5
	_die()

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
