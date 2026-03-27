extends Entity

class_name PathfindingEnemy

@export var enemy_type :Stats.EnemyType = Stats.EnemyType.MUSHROOM
@export var death_sound :AudioStreamMP3 
@export var seconds_waiting :float = 2
var seconds_waited :float = 0
@export var speed :int = 100
@export var path_axis :axis = axis.horizontal
@onready var ray :RayCast2D = $RayCast2D
@onready var anim :AnimatedSpriteComponent = $AnimatedSprite2D
var point_positive :PathfindingPoint
var point_negative :PathfindingPoint
var target_point :PathfindingPoint
var valid_path_direction :Vector2
var dead :bool = false

var seconds_between_point_retry :float = 0.1
var seconds_since_points_check :float = 0.0

var random_floats :Array[float] = []

enum axis {
	vertical,
	horizontal
}	

func _process(delta: float) -> void:
	if dead:
		return
		
	if not point_positive or not point_negative:
		if seconds_since_points_check < seconds_between_point_retry:
			seconds_since_points_check += delta
		else:
			seconds_since_points_check = 0.0
			if path_axis == axis.vertical:
				_search_for_points(Vector2(0, 1))
			else:
				_search_for_points(Vector2(1, 0))

	if _get_direction().x > 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	
	if _is_valid_pathfinding():
		var gpos :Vector2 = target_point.global_position
		var distance :float = global_position.distance_to(gpos)
		
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
		
		var dis_p :float = global_position.distance_to(point_positive.global_position)
		var dis_n :float = global_position.distance_to(point_negative.global_position)
		
		if dis_p >= dis_n:
			target_point = point_positive
		else:
			target_point = point_negative
		
		seconds_waited = 0
		valid_path_direction = global_position.direction_to(target_point.global_position)
		
		return
		
	
	return

func _can_move() -> bool:
	return true

func _move_towards_position(delta: float, gpos: Vector2) -> void:
	var dir :Vector2 = global_position.direction_to(gpos)
	global_position += dir * speed * delta

func _search_for_points(vec: Vector2) -> void:
	ray.target_position = -vec * 1000
	ray.force_raycast_update()
	var c :Object = ray.get_collider()
	if c is not PathfindingPoint:
		return
	
	point_negative = c
	
	ray.target_position = vec * 1000
	ray.force_raycast_update()
	c = ray.get_collider()
	if c is not PathfindingPoint:
		return
	
	point_positive = c
	if random_floats[0] < 0.5:
		target_point = point_positive
	else:
		target_point = point_negative
	
	global_position = lerp(point_negative.global_position, point_positive.global_position, random_floats[1])

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

@rpc("any_peer","call_local","reliable")
func die() -> void:
	anim.play("Hit")
	anim.death()
	$HitArea.set_deferred("monitoring", false)
	$HitArea.set_deferred("monitorable", false)
	AudioManager.play_global_sound(death_sound, 0)
	dead = true

func _is_valid_pathfinding() -> bool:
	return point_negative != null && point_positive != null

func _on_reset() -> void:
	anim.play("Idle")
	$HitArea.set_deferred("monitoring", true)
	$HitArea.set_deferred("monitorable", true)
	dead = false
	point_positive = null
	point_negative = null
	seconds_since_points_check = 0.0
