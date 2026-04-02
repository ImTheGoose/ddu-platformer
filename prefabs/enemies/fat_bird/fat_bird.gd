extends Entity
@export_group("Nodes")
@export var health_component :HealthComponent
@export var sprite_component :EnemySpriteComponent
@export var player_detection_component :PlayerDetectionComponent

func _process(delta: float) -> void:
	if health_component:
		if health_component.is_dead():
			return
	
	if player_detection_component.is_detecting_player():
		if sprite_component.animation != "Fall":
			sprite_component.play("Fall")
		return

	sprite_component.play("Idle")

func _on_reset() -> void:
	sprite_component.play("Idle")
