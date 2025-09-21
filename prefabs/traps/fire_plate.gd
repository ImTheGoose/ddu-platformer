extends StaticBody2D

@onready var audio_burning = preload("res://assets/audio/sfx/fire.mp3")
@onready var audio_clicked = preload("res://assets/audio/sfx/click.mp3")

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
	
	if time_since_hit >= seconds_before_fire && hit_area.monitoring == false:
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
	AudioManager.play_global_sound(audio_burning, -10)

func _hit_plate():
	hit = true
	anim.play("Hit")
	AudioManager.play_global_sound(audio_clicked, -4)

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_hit_plate()
