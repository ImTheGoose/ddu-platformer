extends Node

class_name AudioComponent

@export_group("Death Audio")
@export var health_component :HealthComponent
@export var death_sound :AudioStreamMP3 = preload("uid://yv1k7suwtmf1")

func _ready() -> void:
	if health_component && death_sound:
		health_component.death.connect(_on_death)

func _on_death() -> void:
	AudioManager.play_global_sound(death_sound, 0)
