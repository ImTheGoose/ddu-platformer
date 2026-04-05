extends Entity

@export_group("Nodes")
@export var health_component :HealthComponent
@export var movement_component :MovementComponent
@export var path_detection_component :PathDetectionComponent
@export var sprite_component :EnemySpriteComponent

func _process(delta: float) -> void:
	if health_component:
		if health_component.is_dead():
			return
	
	if movement_component.is_moving():
		sprite_component.play("Moving")
		return
	
	if movement_component.is_at_target() or !movement_component.is_able_to_move():
		sprite_component.play("Idle")

func _on_reset() -> void:
	sprite_component.play("Idle")
