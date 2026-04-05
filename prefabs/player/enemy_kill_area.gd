extends Area2D

@export var player_parent :Player

func _init() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if is_multiplayer_authority():
		if area is HitBoxComponent:
			if not area.health_component:
				return
			
			if area.health_component.is_dead():
				return
			player_parent.double_jumped = false
			Stats.add_recording_value(Stats.StatType.JUMPS_KILL, 1)
			area.health_component.rpc("die")
			player_parent.knockback(Vector2(0, -1), 350, true)
		return
