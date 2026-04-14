extends Entity

@export var enemy_sprite_component :EnemySpriteComponent
@export var movement_component :MovementComponent
@export var wall_killer :Node2D
@export var on_screen :VisibleOnScreenNotifier2D

var direction :Vector2 = Vector2.UP

func _ready() -> void:
	movement_component.target_reached.connect(_on_target_reached)
	movement_component.target_changed.connect(_on_target_changed)
	enemy_sprite_component.animation_finished.connect(_on_animation_finished)
	_on_animation_finished()

func _on_target_changed() -> void:
	var target_pos :Vector2 = movement_component.get_target_position()
	var dir :Vector2 = global_position.direction_to(target_pos)
	direction = get_snapped_vector(dir)
	if wall_killer:
		wall_killer.rotation = direction.angle()

func get_snapped_vector(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		# It's more horizontal than vertical
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		# It's more vertical than horizontal
		return Vector2.DOWN if dir.y > 0 else Vector2.UP
func _on_animation_finished() -> void:
	enemy_sprite_component.play("Idle")

func _on_target_reached() -> void:
	if on_screen && on_screen.is_on_screen():
		GameManager.add_camera_trauma.emit(0.25)
	match direction:
		Vector2.UP:
			enemy_sprite_component.play("Top_Hit")
		Vector2.DOWN:
			enemy_sprite_component.play("Bottom_Hit")
		Vector2.LEFT:
			enemy_sprite_component.play("Left_Hit")
		Vector2.RIGHT:
			enemy_sprite_component.play("Right_Hit")
	return
