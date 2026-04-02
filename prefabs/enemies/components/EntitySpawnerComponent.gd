extends Node2D

class_name EntitySpawnerComponent 

@export var health_component: HealthComponent
@export var entity_type :EntitySpawner.SpawnType

func _ready() -> void:
	if health_component:
		health_component.death.connect(_on_death)

func _on_death() -> void:
	spawn_entity()

func spawn_entity(type: EntitySpawner.SpawnType = entity_type) -> void:
	GameManager.spawn_entity.emit(global_position, type)
