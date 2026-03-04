extends PathfindingEnemy

class_name PlayerDetectingEnemy

@onready var playerRay :RayCast2D = $PlayerRay
@export var attacking_frame :int = 7
@export var seconds_between_attacks :float = 3
var seconds_since_attack :float
var attacking :bool = false
var detected_player :bool = false

func _process(delta: float) -> void:
	super(delta)
	if dead:
		return
	
	seconds_since_attack += delta

	var dir :Vector2 = _get_direction()
	playerRay.target_position = dir * 1000
	
	var c :Object = playerRay.get_collider()
	if c is CharacterBody2D:
		_attempt_attack()
		detected_player = true
		return
	
	detected_player = false

func _attempt_attack() -> void:
	if seconds_since_attack < seconds_between_attacks:
		return
	
	attacking = true
	anim.play("Attack")

func _attack() -> void:
	seconds_since_attack = 0
	attacking = false
	anim.queue_animation("Idle")

func _can_move() -> bool:
	return !detected_player

func _on_animated_sprite_2d_frame_changed() -> void:
	if !anim:
		return
	
	if anim.frame != attacking_frame:
		return
	
	if attacking:
		_attack()
	
	pass # Replace with function body.
