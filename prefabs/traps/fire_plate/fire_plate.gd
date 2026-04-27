extends Entity 

@onready var fire_sounds :Dictionary[AudioStream, float] = {
	preload("uid://bcaume7howqo6") : .85,
}
@onready var click_sounds :Dictionary[AudioStream, float] = {
	preload("uid://m6484ap3pala") : 1.2,
}
@onready var fire_particle: ToggleableParticle = %Fire_Particle

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area :HitArea = $HitArea
@export var seconds_before_fire :float = 1
@export var seconds_burning_for :float = 2
var time_since_hit :float = 0
var hit :bool = false

func _process(delta: float) -> void:
	if hit:
		time_since_hit += delta
	
	if time_since_hit >= (seconds_before_fire * Difficulty.get_setting(Difficulty.Settings.TRAP_TIMER_SPEED_SCALE, 1.0)) + seconds_burning_for:
		_reset_plate()
		return
	
	if time_since_hit >= (seconds_before_fire * Difficulty.get_setting(Difficulty.Settings.TRAP_TIMER_SPEED_SCALE, 1.0)) && hit_area.monitoring == false:
		_start_burning()

func _reset_plate() -> void:
	_stop_burning()
	hit = false
	time_since_hit = 0.0

func _stop_burning() -> void:
	anim.play("Off")
	hit_area.monitoring = false
	
func _start_burning() -> void:
	fire_particle.restart()
	fire_particle.emitting = true
	anim.play("On")
	hit_area.monitoring = true
	Audio.play_random_pitched(fire_sounds)

@rpc("any_peer","call_local","reliable")
func show_hit() -> void:
	hit = true
	anim.play("Hit")
	Audio.play_random_pitched(click_sounds)

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_multiplayer_authority():
			rpc("show_hit")

func _on_reset() -> void:
	_reset_plate()
