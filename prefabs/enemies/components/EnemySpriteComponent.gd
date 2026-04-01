extends AnimatedSprite2D

class_name EnemySpriteComponent 

@export var entity_node :Entity
@export var health_component :HealthComponent
@export var path_detection_component :PathDetectionComponent
@export var movement_component :MovementComponent
var target_rotation :float = 0.0
var velocity :Vector2 = Vector2.ZERO
var origin_pos :Vector2 = position

func _ready() -> void:
	if health_component:
		health_component.death.connect(_on_death)
	
	if path_detection_component:
		path_detection_component.direction_changed.connect(_on_direction_changed)
	
	if movement_component:
		movement_component.movement_state_changed.connect(_on_movement_changed)
		pass
	
	origin_pos = position
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)

func _on_movement_changed() -> void:
	if health_component:
		if health_component.is_dead():
			return

	if movement_component.is_waiting():
		play("Idle")
	else:
		play("Moving")

func _on_direction_changed(new_dir: Vector2) -> void:
	if new_dir.x > 0:
		flip_h = true
	else:
		flip_h = false

func _on_death() -> void:
	play("Hit")
	target_rotation = randf_range(-35, 35)
	velocity = Vector2(randf_range(-150, 150), randf_range(-100, -600))

func _on_entity_reset() -> void:
	play("Idle")
	target_rotation = 0.0
	velocity = Vector2.ZERO
	position = origin_pos
	rotation_degrees = 0

func _process(delta: float) -> void:	
	if target_rotation == 0:
		return

	velocity.y += 1100 * delta
	global_position += velocity * delta
	rotation = lerp_angle(rotation, target_rotation, delta)
