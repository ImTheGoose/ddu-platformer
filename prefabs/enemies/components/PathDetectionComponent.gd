extends RayCast2D

class_name PathDetectionComponent 

@export var entity_node :Entity
@export var path_axis :Axis = Axis.HORIZONTAL

signal direction_changed(new_dir: Vector2)
signal valid_path_detected

var point_negative :PathfindingPoint
var point_positive :PathfindingPoint
var taget_point :PathfindingPoint:
	set(value):
		taget_point = value
		direction_changed.emit(get_direction())

var seconds_between_point_retry :float = 0.1
var seconds_since_points_check :float = 0.0

enum Axis {
	HORIZONTAL,
	VERTICAL,
}

func _ready() -> void:
	collide_with_areas = true
	
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)

func _process(delta: float) -> void:
	if not is_valid_path():
		if seconds_between_point_retry > seconds_since_points_check:
			seconds_since_points_check += delta
		else:
			seconds_since_points_check = 0.0
			_search_for_points()

func _on_entity_reset() -> void:
	point_positive = null
	point_negative = null
	taget_point = null
	seconds_since_points_check = 0.0
	return

func _get_axis_direction() -> Vector2:
	match path_axis:
		Axis.HORIZONTAL:
			return Vector2(1, 0)
		Axis.VERTICAL:
			return Vector2(0, 1)
	return Vector2.ZERO

func _search_for_points() -> void:
	var positive_dir :Vector2 = _get_axis_direction()
	var positive_collider :Object = _get_ray_collission(positive_dir)
	if positive_collider is PathfindingPoint:
		point_positive = positive_collider
	
	var negative_collider :Object = _get_ray_collission(-positive_dir)
	if negative_collider is PathfindingPoint:
		point_negative = negative_collider
	
	if is_valid_path():
		taget_point = point_positive
		valid_path_detected.emit()
	
	direction_changed.emit(get_direction())
	
	return

func _get_ray_collission(dir: Vector2) -> Object:
	target_position = dir * 1000
	force_raycast_update()
	return get_collider()

#region Helper Functions

func get_target() -> Node2D:
	return taget_point

func swap_target() -> void:
	if not is_valid_path():
		return
	
	if taget_point == point_positive:
		taget_point = point_negative
	else:
		taget_point = point_positive

func get_direction() -> Vector2:
	if is_valid_path():
		return global_position.direction_to(taget_point.global_position)
	elif point_negative != null:
		return global_position.direction_to(point_negative.global_position)
	else:
		return _get_axis_direction()

func is_valid_path() -> bool:
	if point_positive != null && point_negative != null:
		return true
	return false

#endregion
