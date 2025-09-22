extends Node2D

class_name PathfindingEnemy

@export var seconds_waiting :float = 2
var seconds_waited :float = 0
@export var speed :int = 100
@export var path_axis :axis = axis.horizontal
@onready var ray :RayCast2D = $RayCast2D
@onready var anim :AnimatedEntitySprite2D = $AnimatedSprite2D
var point_positive :PathfindingPoint
var point_negative :PathfindingPoint
var checked_points = false
var target_point :PathfindingPoint
var valid_path_direction :Vector2

enum axis {
	vertical,
	horizontal
}

func _init() -> void:
	var spawn_rate = min(GameManager.get_difficulty_value("enemy_spawn_rate"), 1.0)
	var rand_float = randf()
	if rand_float > spawn_rate:
		queue_free()
	

func _process(delta: float) -> void:
	if !checked_points:
		if path_axis == axis.vertical:
			_get_points(Vector2(0, 1))
		else:
			_get_points(Vector2(1, 0))
	
	if _get_direction().x > 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	
	if _is_valid_pathfinding():
		var gpos = target_point.global_position
		var distance = global_position.distance_to(gpos)
		
		if !_can_move():
			return
		
		if distance > 1 && global_position.direction_to(point_positive.global_position) != global_position.direction_to(point_negative.global_position):
			_move_towards_position(delta, gpos)
			anim.play("Moving")
			
			return
		
		if seconds_waited < seconds_waiting:
			seconds_waited += delta
			global_position = gpos
			anim.play("Idle")
			return
		
		var dis_p = global_position.distance_to(point_positive.global_position)
		var dis_n = global_position.distance_to(point_negative.global_position)
		
		if dis_p >= dis_n:
			target_point = point_positive
		else:
			target_point = point_negative
		
		seconds_waited = 0
		valid_path_direction = global_position.direction_to(target_point.global_position)
		
		return
		
	
	return

func _can_move():
	return true

func _move_towards_position(delta: float, gpos: Vector2):
	var dir = global_position.direction_to(gpos)
	global_position += dir * speed * delta

func _get_points(vec: Vector2):
	checked_points = true
	ray.target_position = -vec * 1000
	ray.force_raycast_update()
	var c = ray.get_collider()
	if c is not PathfindingPoint:
		return
	
	point_negative = c
	
	ray.target_position = vec * 1000
	ray.force_raycast_update()
	c = ray.get_collider()
	if c is not PathfindingPoint:
		return
	
	point_positive = c
	if randf() < 0.5:
		target_point = point_positive
	else:
		target_point = point_negative
	

	if point_negative.global_position.y == point_positive.global_position.y:
		var ran_gpos = randf_range(point_negative.global_position.x, point_positive.global_position.x)
		global_position.x = ran_gpos
	else: 
		var ran_gpos = randf_range(point_negative.global_position.y, point_positive.global_position.y)
		global_position.y = ran_gpos

	valid_path_direction = global_position.direction_to(target_point.global_position)

func _get_direction() -> Vector2:
	if _is_valid_pathfinding():
		return valid_path_direction
	elif point_positive != null:
		return global_position.direction_to(point_positive.global_position)
	elif point_negative != null:
		return global_position.direction_to(point_negative.global_position)
	else:
		return Vector2(1, 0)

func _is_valid_pathfinding() -> bool:
	return point_negative != null && point_positive != null
