extends RayCast2D

class_name P2PTargetingComponent 

@export var entity_node :Entity
@export var movement_component :MovementComponent
var target_point :PathfindingPoint
var previous_point :PathfindingPoint

@export_range(0,5, 0.1) var seconds_waiting_at_target :float = 2.0
var seconds_waited :float = 0.0

var seconds_between_point_retry :float = 0.1
var seconds_since_points_check :float = 0.0

func _ready() -> void:
	if movement_component:
		movement_component.target_reached.connect(_on_target_reached)
	
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)
	
	movement_component.start_moving()

func _process(delta: float) -> void:
	if not target_point:
		movement_component.block_movement()
		if seconds_since_points_check < seconds_between_point_retry:
			seconds_since_points_check += delta
		else:
			seconds_since_points_check = 0.0
			_update_target()
	else:
		movement_component.resume_movement()
	
	if movement_component.is_at_target():
		if seconds_waited < seconds_waiting_at_target:
			seconds_waited += delta
		else:
			seconds_waited = 0.0
			_update_target()
			movement_component.start_moving()
		

func _on_target_reached() -> void:
	movement_component.stop_moving()

func _update_target() -> void:
	var gpos :Vector2 = entity_node.global_position
	var detected_points :Array[PathfindingPoint] = get_detected_points()
	if detected_points.is_empty():
		if previous_point:
			movement_component.set_target(previous_point.global_position)
		return
	
	if detected_points.size() > 1:
		if previous_point:
			for point in detected_points:
				if point == previous_point:
					detected_points.erase(point)
	if detected_points.size() == 1:
		previous_point = target_point
		movement_component.set_target(detected_points[0].global_position)
		target_point = detected_points[0]
		return
		
	var closest_point :PathfindingPoint = detected_points[0]
	for point in detected_points:
		if gpos.distance_to(point.global_position) < gpos.distance_to(closest_point.global_position):
			closest_point = point
	
	previous_point = target_point
	movement_component.set_target(closest_point.global_position)
	target_point = closest_point

func _on_entity_reset() -> void:
	previous_point = null
	target_point = null
	_update_target()
	movement_component.start_moving()

func get_detected_points() -> Array:
	var directions :Array[Vector2] = [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]
	var detected_points :Array[PathfindingPoint] = []
	for dir in directions:
		var point :PathfindingPoint = get_point(dir)
		if point:
			detected_points.append(point)
	
	return detected_points

func get_point(direction: Vector2) -> PathfindingPoint:
	target_position = direction * 500
	force_raycast_update()
	if is_colliding():
		var col :Object = get_collider()
		if col is PathfindingPoint:
			return col
	
	return null
