extends AnimatedSprite2D

class_name AnimatedSpriteComponent

@export var entity_node :Entity
var target_rot :float = 0.0
var start_vel :Vector2 = Vector2.ZERO
var origin_pos :Vector2 = position

func _init() -> void:
	animation_looped.connect(_on_animation_looped)

func _ready() -> void:
	origin_pos = position
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)

func _on_entity_reset() -> void:
	target_rot = 0.0
	start_vel = Vector2.ZERO
	position = origin_pos
	rotation_degrees = 0

func _process(delta: float) -> void:	
	if target_rot == 0:
		return

	start_vel.y += 1100 * delta
	global_position += start_vel * delta
	rotation = lerp_angle(rotation, target_rot, delta)

func death() -> void:
	target_rot = randf_range(-35, 35)
	start_vel = Vector2(randf_range(-150, 150), randf_range(-100, -600))

var queued_anim :String = ""


func queue_animation(_name: String) -> void:
	queued_anim = _name	

func _on_animation_looped() -> void:
	if queued_anim != "":
		play(queued_anim)
		queued_anim = ""
