extends Area2D

class_name HitArea

@export var kill_type :Stats.KillType = Stats.KillType.SPIKE
@onready var position_node :Node2D = get_child(0)

func _init() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_multiplayer_authority():
			Stats.set_recording_value(Stats.StatType.RECORDING_DEATH_TYPE, kill_type)
			body.hit(position_node.global_position.direction_to(body.global_position))
			pass
