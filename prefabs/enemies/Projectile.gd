extends Area2D

class_name Projectile

@export var speed :int = 100
@export var particles :GPUParticles2D
@onready var sprite :Sprite2D = $Sprite2D
@onready var col :CollisionShape2D = $CollisionShape2D
var direction :Vector2 = Vector2(1, 0)

const SECONDS_BEFORE_CLEAR :float = 5.0
var seconds_since_collission :float = 0.0

func _init() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	GameManager.client_reset.connect(queue_free)
	

func _ready() -> void:
	particles.restart()
	particles.emitting = false
	speed *= Difficulty.get_setting(Difficulty.Settings.PROJECTILE_SPEED_SCALE, 1.0)

func _process(delta: float) -> void:
	global_position += direction.rotated(global_rotation) * speed * delta
	if seconds_since_collission > 0.0:
		if seconds_since_collission > SECONDS_BEFORE_CLEAR:
			queue_free()
		else:
			seconds_since_collission += delta

func _on_area_entered(area: Area2D) -> void:
	if area is Projectile:
		_hit_something()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.is_multiplayer_authority():
			Stats.set_recording_value(Stats.StatType.RECORDING_DEATH_TYPE, Stats.StatType.DEATH_TRUNK)
			body.hit(col.global_position.direction_to(body.global_position))
			_hit_something()
	if body is TileMapLayer:
		_hit_something()

func _hit_something() -> void:
	particles.restart()
	particles.emitting = true
	seconds_since_collission = 0.1
	col.set_deferred("disabled", true)
	speed = 0
	sprite.visible = false
	
	
