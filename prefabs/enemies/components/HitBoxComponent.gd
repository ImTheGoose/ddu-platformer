extends Area2D

class_name HitBoxComponent 

@export var kill_type :Stats.KillType = Stats.KillType.SPIKE
@export var knockback_origin_node: Node2D
@export var health_component: HealthComponent
@export var kill_height_node :Node2D
@export var kill_veloctiy_treshold :float
@export var entity_node :Entity
var killed_peer_id: int = -1

func _ready() -> void:
	if !knockback_origin_node:
		return
	
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)
	
	body_entered.connect(_on_body_entered)

func disable_hitbox() -> void:
	monitorable = false
	monitoring = false

func enable_hitbox() -> void:
	monitorable = true
	monitoring = true

func _on_entity_reset() -> void:
	killed_peer_id = -1

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not body.is_multiplayer_authority():
			return
		
		if health_component:
			if health_component.is_dead() or health_component.is_immune():
				return
		
		var gpos :Vector2 = kill_height_node.global_position
		var feet_gpos :Vector2 = body.get_feet_node().global_position
		var dir :Vector2 = gpos.direction_to(feet_gpos)


		Stats.set_recording_value(Stats.StatType.RECORDING_DEATH_TYPE, kill_type)
		body.hit(knockback_origin_node.global_position.direction_to(body.global_position))
		killed_peer_id = body.get_multiplayer_authority()
