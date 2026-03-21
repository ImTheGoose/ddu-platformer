extends Area2D

class_name Projectile

@export var speed :int = 300
@onready var col :CollisionShape2D = $CollisionShape2D
var direction :Vector2 = Vector2(-1, 0)

func _init() -> void:
	body_entered.connect(_on_body_entered)
	GameManager.client_reset.connect(queue_free)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	
	rotation = -direction.angle()
	
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		StatisticManager.set_value("death_type", StatisticManager.death_type.trunk)
		body.hit(col.global_position.direction_to(body.global_position))
		pass
	if body is TileMapLayer:
		queue_free()	
	
