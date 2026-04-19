extends RayCast2D

class_name PathDetectionComponent 

@export var entity_node :Entity
@export var path_axis :Axis = Axis.HORIZONTAL

signal direction_changed(new_dir: Vector2)
signal valid_path_detected

var forced_point_direction :int = 0
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
	set_collision_mask_value(5, true)
	
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)

func _process(delta: float) -> void:
	if not is_valid_path():
		if seconds_between_point_retry > seconds_since_points_check:
			seconds_since_points_check += delta
		else:
			seconds_since_points_check = 0.0
			_search_for_points()
	else:
		enabled = false

func _on_entity_reset() -> void:
	
	forced_point_direction = 0
	point_positive = null
	point_negative = null
	taget_point = null
	seconds_since_points_check = 0.0
	enabled = true
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
	var positive_collider :PathfindingPoint = _get_ray_collission(positive_dir)
	if positive_collider:
		point_positive = positive_collider
	
	var cached_point :PathfindingPoint = null
	
	if _is_collission_inside():
		cached_point = _get_ray_collission(positive_dir, false)
	
	var negative_collider :PathfindingPoint = _get_ray_collission(-positive_dir)
	if negative_collider:
		point_negative = negative_collider
	
	if _is_collission_inside():
		var cached_neg_point :PathfindingPoint = _get_ray_collission(-positive_dir, false)
		var gpos :Vector2 = entity_node.global_position
		if cached_point && cached_neg_point:
			if gpos.distance_to(cached_point.global_position) < gpos.distance_to(cached_neg_point.global_position):
				point_positive = cached_point
			else:
				point_negative = cached_neg_point
		elif cached_point:
			point_positive = cached_point
		elif cached_neg_point:
			point_negative = cached_neg_point
	
	if is_valid_path():
		if entity_node.enabled_modifiers.has(Entity.EntityModifiers.INITIAL_DIRECTION_NEGATIVE):
			taget_point = point_negative
		else:
			taget_point = point_positive
		
		if forced_point_direction == -1:
			taget_point = point_negative
		elif forced_point_direction == 1:
			taget_point = point_positive
		
		valid_path_detected.emit()
	
	direction_changed.emit(get_direction())
	
	return



func _is_collission_inside() -> bool:
	return get_collision_point() == global_position

func _get_ray_collission(dir: Vector2, inside_hit: bool = true) -> PathfindingPoint:
	hit_from_inside = inside_hit
	target_position = dir * 2000
	force_raycast_update()
	
	if get_collider() is PathfindingPoint:
		return get_collider()
	return null

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

@rpc("authority", "call_local", "reliable")
func set_target(to_positive_point: bool) -> void:
	if to_positive_point:
		forced_point_direction = 1
		taget_point = point_positive
	else:
		forced_point_direction = -1
		taget_point = point_negative

func get_direction() -> Vector2:
	if is_valid_path():
		if taget_point == point_positive:
			return _get_axis_direction()
		else:
			return Vector2(-1, -1) * _get_axis_direction()
	elif point_negative != null:
		return Vector2(-1, -1) * _get_axis_direction()
	else:
		return _get_axis_direction()

func is_valid_path() -> bool:
	if point_positive != null && point_negative != null:
		return true
	return false

#endregion
