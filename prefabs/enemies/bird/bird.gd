extends Entity
@export_group("Nodes")
@export var health_component :HealthComponent
@export var sprite_component :EnemySpriteComponent

func _process(delta: float) -> void:
	if health_component:
		if health_component.is_dead():
			return
	
	sprite_component.play("Moving")

func _on_reset() -> void:
	sprite_component.play("Moving")
