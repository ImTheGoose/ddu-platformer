extends RayCast2D

class_name TrapPathDetectionComponent 

@export var entity_node :Entity
@export var search_direction :SearchDirection = SearchDirection.UP

@export var use_terrain_as_point :bool = false
@export_range(0, 256, 1.0) var max_distance_to_terrain :float = 0

signal path_changed

var path_point :PathfindingPoint = null
var terrain_collission_position :Vector2 = Vector2.ZERO

enum SearchDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

func _ready() -> void:
	set_collision_mask_value(6, true)
	collide_with_areas = true
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)

func _process(delta: float) -> void:
	if path_point:
		enabled = false
		return
	if is_colliding():
		var col :Object = get_collider()
		if col is PathfindingPoint:
			if not path_point:
				path_point = col
				path_changed.emit()
				
		elif col is TileMapLayer:
			if use_terrain_as_point:
				if terrain_collission_position == Vector2.ZERO:
					terrain_collission_position = get_collision_point()
					path_changed.emit()
			

func _on_entity_reset() -> void:
	target_position = _get_direction() * 1000
	terrain_collission_position = Vector2.ZERO
	path_point = null
	enabled = true

func get_detected_position() -> Vector2:
	if path_point:
		return path_point.global_position
	
	if use_terrain_as_point:
		if terrain_collission_position != Vector2.ZERO:
			if global_position.distance_to(terrain_collission_position) < max_distance_to_terrain:
				return terrain_collission_position
	
	return Vector2.ZERO

func _get_direction() -> Vector2:
	match search_direction:
		SearchDirection.DOWN:
			return Vector2.DOWN
		SearchDirection.LEFT:
			return Vector2.LEFT
		SearchDirection.RIGHT:
			return Vector2.RIGHT
		_:
			return Vector2.UP
