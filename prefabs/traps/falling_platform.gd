extends RigidBody2D

@onready var origin_pos :Vector2 = position
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var col :CollisionShape2D = $CollisionShape2D
@export var seconds_before_reappear :float = 5
@export var seconds_before_fall :float = 1
var fall_time :float = 0
var touched :bool = false


func _process(delta: float) -> void:
	if fall_time > seconds_before_reappear + seconds_before_fall:
		_initiate_platform_reappear()
	
	if touched:
		fall_time += delta
		
	if fall_time > seconds_before_fall:
		_initiate_platform_fall()

func _initiate_platform_reappear():
	anim.play("On")
	anim.frame = 0
	gravity_scale = 0
	position = origin_pos
	col.disabled = false
	fall_time = 0
	touched = false
	linear_velocity.y = 0
	
func _initiate_platform_fall():
	anim.pause()
	col.disabled = true
	gravity_scale = 1

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		touched = true
		pass
