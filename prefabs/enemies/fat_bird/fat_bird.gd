extends Entity
@export_group("Nodes")
@export var health_component :HealthComponent
@export var sprite_component :EnemySpriteComponent
@export var player_detection_component :PlayerDetectionComponent
@export var movement_component :MovementComponent
@export var collission_targeting_component :CollissionTargetingComponent
@export var on_screen :VisibleOnScreenNotifier2D

func _ready() -> void:
	movement_component.target_reached.connect(_on_target_reached)

func _on_target_reached() -> void:
	if collission_targeting_component.moving_towards_collission:
		sprite_component.play("Ground")
		if on_screen && on_screen.is_on_screen():
			GameManager.add_camera_trauma.emit(0.3)

func _process(delta: float) -> void:
	if health_component:
		if health_component.is_dead():
			return
	
	if movement_component.is_moving():
		if collission_targeting_component.moving_towards_collission:
			sprite_component.play("Fall")
			return
	elif sprite_component.animation == "Ground":
		if sprite_component.is_playing():
			return

	sprite_component.play("Idle")

func _on_reset() -> void:
	sprite_component.play("Idle")
