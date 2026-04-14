extends AnimatedSprite2D

class_name EnemySpriteComponent 

@export var entity_node :Entity
@export var health_component :HealthComponent
@export var path_detection_component :PathDetectionComponent
@export var flip_x_offset :bool = false
var unflipped_x_offset :float = position.x
var target_rotation :float = 0.0
var velocity :Vector2 = Vector2.ZERO
var origin_pos :Vector2 = position

signal flipped_h

func _ready() -> void:
	if health_component:
		health_component.death.connect(_on_death)
	
	if path_detection_component:
		path_detection_component.direction_changed.connect(_on_direction_changed)
	
	unflipped_x_offset = offset.x
	origin_pos = position
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)

func _on_direction_changed(new_dir: Vector2) -> void:
	if new_dir.x > 0:
		if flip_x_offset:
			offset.x = -unflipped_x_offset
		flip_h = true
	else:
		if flip_x_offset:
			offset.x = unflipped_x_offset
		flip_h = false
	flipped_h.emit()

func _on_death() -> void:
	play("Hit")
	target_rotation = randf_range(-35, 35)
	velocity = Vector2(randf_range(-50, 50), randf_range(-50, -200))

func _on_entity_reset() -> void:
	target_rotation = 0.0
	velocity = Vector2.ZERO
	position = origin_pos
	rotation_degrees = 0

func _process(delta: float) -> void:	
	if target_rotation == 0:
		return

	velocity.y += 350 * delta
	global_position += velocity * delta
	rotation = lerp_angle(rotation, target_rotation, delta)
