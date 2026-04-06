extends Node

class_name AudioComponent

@export_group("Death Audio")
@export var health_component :HealthComponent
@export var death_sound :AudioStreamMP3 = preload("uid://yv1k7suwtmf1")

@export_group("Projectile Audio")
@export var projectile_spawner :ProjectileSpawnerComponent
@export var projectile_sound :AudioStream = preload("uid://u1tef53jrusq")

func _ready() -> void:
	if health_component && death_sound:
		health_component.death.connect(_on_death)
	
	if projectile_spawner && projectile_sound:
		projectile_spawner.projectile_spawned.connect(_on_projectile_spawned)

func _on_projectile_spawned() -> void:
	AudioManager.play_global_sound(projectile_sound, -3)

func _on_death() -> void:
	AudioManager.play_global_sound(death_sound, 0)
