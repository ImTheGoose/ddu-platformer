extends Area2D

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_collect :AudioStreamMP3 = preload("uid://cyi6b5lna87oj")


func _init() -> void:
	var spawn_rate :float = min(GameManager.get_difficulty_value("collectable_spawn_rate"), 1.0)
	var rand_float :float = randf()
	if rand_float > spawn_rate:
		queue_free()

func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		anim.play("Collect")
		var money :Variant = DataManager.get_value("money")
		DataManager.set_value("money", money + 1) 
		StatisticManager.add_value("apples_collected", 1)
		AudioManager.play_global_sound(audio_collect, -9)
		pass

func _on_anim_finished() -> void:
	self.queue_free()
	
