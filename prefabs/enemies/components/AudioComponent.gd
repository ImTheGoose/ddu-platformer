extends Node

class_name AudioComponent

@export var on_screen_notifier :VisibleOnScreenNotifier2D

@export_group("Death Audio")
@export var health_component :HealthComponent
@export var death_sound :AudioStreamMP3 = preload("uid://yv1k7suwtmf1")

@export_group("Projectile Audio")
@export var projectile_spawner :ProjectileSpawnerComponent
@export var projectile_sound :AudioStream = preload("uid://u1tef53jrusq")

@export_group("Movement Audio")
@export var movement_component: MovementComponent
@export var target_reached_collision_ray :RayCast2D
@export var target_reached_sound :AudioStream

func _ready() -> void:
	if health_component && death_sound:
		health_component.death.connect(_on_death)
	
	if projectile_spawner && projectile_sound:
		projectile_spawner.projectile_spawned.connect(_on_projectile_spawned)
	
	if movement_component:
		movement_component.target_reached.connect(_on_target_reached)

func _on_target_reached() -> void:
	if target_reached_collision_ray:
		if not target_reached_collision_ray.is_colliding():
			return
	
	if not target_reached_sound:
		return
	
	if not _is_visible():
		return
	
	AudioManager.play_global_sound(target_reached_sound, -3)

func _on_projectile_spawned() -> void:
	if _is_visible():
		AudioManager.play_global_sound(projectile_sound, -3)

func _on_death() -> void:
	if _is_visible():
		AudioManager.play_global_sound(death_sound, 0)

func _is_visible() -> bool:
	if on_screen_notifier:
		return on_screen_notifier.is_on_screen()
	return true
