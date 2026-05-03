extends Area2D

class_name HurtBoxComponent

@export var health_component :HealthComponent
@export var hitbox_component :HitBoxComponent

func _ready() -> void:
	if not health_component:
		return
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not body.is_multiplayer_authority():
			return

		#await get_tree().physics_frame
		#if hitbox_component:
			#if hitbox_component.killed_peer_id == body.get_multiplayer_authority():
				#return
		

		if not health_component.is_dead():
			health_component.rpc("die")
			body.knockback(Vector2(0, -1), 1000, true)
