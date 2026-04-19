extends Node

class_name AudioComponent

@export var on_screen_notifier :VisibleOnScreenNotifier2D

@export_group("Death Audio")
@export var health_component :HealthComponent
@export var death_sounds :Dictionary[AudioStream, float] = {preload("uid://yv1k7suwtmf1"): 0.9}

@export_group("Projectile Audio")
@export var projectile_spawner :ProjectileSpawnerComponent
@export var projectile_sounds :Dictionary[AudioStream, float] = {preload("uid://u1tef53jrusq") : 0.9}

@export_group("Movement Audio")
@export var movement_component: MovementComponent
@export var target_reached_collision_ray :RayCast2D
@export var target_reached_sounds :Dictionary[AudioStream, float]
@export var footstep_sounds :Dictionary[AudioStream, float] = {
	preload("uid://c6j2hoc4wymal") : 0.1,
	preload("uid://oharaq54bnb7") : 0.1,
	preload("uid://doieij1l416q4") : 0.1,
	preload("uid://d508bpeswjo2") : 0.1,
	preload("uid://cv8h3ffkelp3p") : 0.1,
	preload("uid://bfvky0in4lm5m") : 0.1,
	preload("uid://mn7nnq2ff54i") : 0.1,
	preload("uid://c2vtllrrqwp2c") : 0.1,
	preload("uid://kmgk7llkwmhb") : 0.1,
	preload("uid://ckv2j5nn4t23i") : 0.1,
	preload("uid://cxmmcbvtppmhv") : 0.1,
	preload("uid://bjicby1naax2x") : 0.1,
}
@export_range(0, 2, .01) var footstep_pitch_offset :float = 1.0
@export_range(-0.01,0.5) var seconds_between_footsteps :float = -0.01
var seconds_since_footstep :float = 0.0

func _process(delta: float) -> void:
	if on_screen_notifier:
		if not on_screen_notifier.is_on_screen():
			return
	
	if health_component:
		if health_component.is_dead():
			return
	
	if movement_component:
		if seconds_between_footsteps <= 0:
			return
		
		if not movement_component.is_moving():
			return
		
		seconds_since_footstep += delta
		
		if seconds_since_footstep > seconds_between_footsteps:
			seconds_since_footstep = 0.0
			Audio.play_random(footstep_sounds, randf_range(footstep_pitch_offset - .2, footstep_pitch_offset + .2))


func _ready() -> void:
	if health_component && death_sounds:
		health_component.death.connect(_on_death)
	
	if projectile_spawner && projectile_sounds:
		projectile_spawner.projectile_spawned.connect(_on_projectile_spawned)
	
	if movement_component:
		movement_component.target_reached.connect(_on_target_reached)

func _on_target_reached() -> void:
	if target_reached_collision_ray:
		if not target_reached_collision_ray.is_colliding():
			return
	
	if not target_reached_sounds:
		return
	
	if not _is_visible():
		return
	
	Audio.play_random_pitched(target_reached_sounds)

func _on_projectile_spawned() -> void:
	if _is_visible():
		Audio.play_random_pitched(projectile_sounds)

func _on_death() -> void:
	if _is_visible():
		Audio.play_random_pitched(death_sounds)

func _is_visible() -> bool:
	if on_screen_notifier:
		return on_screen_notifier.is_on_screen()
	return true
