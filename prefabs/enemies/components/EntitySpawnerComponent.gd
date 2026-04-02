extends Node2D

class_name EntitySpawnerComponent 

@export var path_detection_component: PathDetectionComponent
@export var movement_component: MovementComponent
@export var health_component: HealthComponent
@export var entity_type :EntitySpawner.SpawnType
@export var amount: int = 2
@export var distance_between: float = 4

func _ready() -> void:
	if health_component:
		health_component.death.connect(_on_death)

func _on_death() -> void:
	spawn_entities()

func spawn_entities(type: EntitySpawner.SpawnType = entity_type) -> void:
	for i in range(amount):
		if movement_component:
			if movement_component.is_at_target():
				if i < amount / 2.0 * path_detection_component.get_direction().x:
					spawn_entity(global_position, type)
					continue
		
		var index: int = i - 2
		var offset :float = distance_between * index	
		var gpos :Vector2 = global_position
		gpos.x += offset	
		spawn_entity(gpos, type)

func spawn_entity(gpos: Vector2, type: EntitySpawner.SpawnType) -> void:
	GameManager.spawn_entity.emit(gpos, type)
