extends StaticBody2D

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area :HitArea = $Area2D
@export var seconds_before_fire :float = 1
@export var seconds_burning_for :float = 2
var time_since_hit :float = 0
var hit := false

func _process(delta: float) -> void:
	if hit:
		time_since_hit += delta
	
	if time_since_hit >= seconds_before_fire + seconds_burning_for:
		_reset_plate()
		return
	
	if time_since_hit >= seconds_before_fire:
		_start_burning()

func _reset_plate():
	_stop_burning()
	hit = false
	time_since_hit = 0

func _stop_burning():
	anim.play("Off")
	hit_area.monitoring = false
	
func _start_burning():
	anim.play("On")
	hit_area.monitoring = true

func _hit_plate():
	hit = true
	anim.play("Hit")

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_hit_plate()
