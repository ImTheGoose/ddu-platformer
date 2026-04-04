extends RigidBody2D
@onready var player_detection: Area2D = %PlayerDetection
@onready var origin_pos :Vector2 = position
@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var col :CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@export var seconds_before_reappear :float = 5
@export var seconds_before_fall :float = 1
var fall_time :float = 0
var touched :bool = false


func _process(delta: float) -> void:
	if not touched:
		for body in player_detection.get_overlapping_bodies():
			if body is Player:
				if body.is_on_floor():
					if body.is_multiplayer_authority():
						rpc("show_touched")

	
	if fall_time > seconds_before_reappear + seconds_before_fall:
		_initiate_platform_reappear()
	
	if touched:
		fall_time += delta
		
	if fall_time > seconds_before_fall:
		_initiate_platform_fall()

func _initiate_platform_reappear() -> void:
	animation_player.play("Appear")
	gpu_particles_2d.emitting = true
	freeze = true
	anim.play("On")
	anim.frame = 0
	position = origin_pos
	rotation_degrees = 0
	col.disabled = false
	fall_time = 0
	touched = false
	linear_velocity.y = 0
	
func _initiate_platform_fall() -> void:
	animation_player.play("Disappear")
	gpu_particles_2d.emitting = false
	freeze = false
	anim.pause()
	col.disabled = true

@rpc("any_peer","call_local","reliable")
func show_touched() -> void:
	animation_player.play("RESET")
	touched = true
	animation_player.play("Touched")


func _on_falling_platform_entity_entity_reset() -> void:
	_initiate_platform_reappear()
