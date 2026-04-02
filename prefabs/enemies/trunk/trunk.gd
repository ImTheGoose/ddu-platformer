extends Entity

@export_group("Nodes")
@export var health_component :HealthComponent
@export var movement_component :MovementComponent
@export var path_detection_component :PathDetectionComponent
@export var sprite_component :EnemySpriteComponent
@export var projectile_spawner_component :ProjectileSpawnerComponent
@export var attack_component :AttackComponent

func _ready() -> void:
	if attack_component:
		attack_component.attack_fired.connect(_on_attack_fired)

func _on_reset() -> void:
	sprite_component.play("Idle")

func _on_attack_fired() -> void:
	projectile_spawner_component.spawn_projectile(path_detection_component.get_direction())

func _process(delta: float) -> void:
	if health_component:
		if health_component.is_dead():
			return
	
	if attack_component.is_attacking():
		return
	
	if movement_component.is_moving():
		sprite_component.play("Moving")
		return
	
	if movement_component.is_at_target() or !path_detection_component.is_valid_path():
		sprite_component.play("Idle")
