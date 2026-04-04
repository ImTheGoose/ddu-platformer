extends RayCast2D

class_name PlayerDetectionComponent 

signal player_detected

@export var health_component :HealthComponent
@export var path_detection_component :PathDetectionComponent
@export var detection_range :int = 500

func _ready() -> void:
	if path_detection_component:
		path_detection_component.direction_changed.connect(_on_direction_changed)
		_on_direction_changed(path_detection_component.get_direction())
	_on_direction_changed(target_position.normalized())

func _process(delta: float) -> void:
	if is_detecting_player():
		player_detected.emit()

func is_detecting_player() -> bool:
	if health_component:
		if health_component.is_dead():
			return false
	
	if is_colliding():
		var collider :Object = get_collider()
		if collider is Player:
			if collider.is_multiplayer_authority():
				return true
	return false

func _on_direction_changed(new_dir: Vector2) -> void:
	target_position = new_dir * detection_range
	return
