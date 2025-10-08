extends Area2D

@onready var anim = $AnimatedSprite2D
@onready var audio_collect = preload("res://assets/audio/sfx/collectable.mp3")


func _init() -> void:
	var spawn_rate = min(GameManager.get_difficulty_value("collectable_spawn_rate"), 1.0)
	var rand_float = randf()
	if rand_float > spawn_rate:
		queue_free()

func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		anim.play("Collect")
		var money = DataManager.get_value("money")
		DataManager.set_value("money", money + 1) 
		StatisticManager.add_value("apples_collected", 1)
		AudioManager.play_global_sound(audio_collect, -9)
		pass

func _on_anim_finished():
	self.queue_free()
	
