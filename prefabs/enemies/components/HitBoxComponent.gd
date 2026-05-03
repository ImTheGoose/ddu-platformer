extends Area2D

class_name HitBoxComponent 

@export var kill_type :Stats.KillType = Stats.KillType.SPIKE
@export var knockback_origin_node: Node2D
@export var health_component: HealthComponent

func _ready() -> void:
	if !knockback_origin_node:
		return

	body_entered.connect(_on_body_entered)

func disable_hitbox() -> void:
	monitorable = false
	monitoring = false

func enable_hitbox() -> void:
	monitorable = true
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not body.is_multiplayer_authority():
			return
		
		if health_component:
			if health_component.is_dead() or health_component.is_immune():
				return

		Stats.set_recording_value(Stats.StatType.RECORDING_DEATH_TYPE, kill_type)
		body.hit(knockback_origin_node.global_position.direction_to(body.global_position))
