extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
var is_hit :bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	animated_sprite_2d.play("Static")
	

func _on_body_entered(body: Node2D) -> void:
	if is_hit:
		return
	
	if body is Player:
		var current_index :int = DataManager.get_value("unlocked_level")
		if current_index == Levels.get_level_index():
			DataManager.set_value("unlocked_level", current_index + 1)
		is_hit = true
		print("Player hit checkpoint")
		animated_sprite_2d.play("Reveal")
		GameManager.set_state(GameManager.STATE.POST_GAME)
		Levels.update_level_time()
		Stats._save_recording()
		MenuHandler.change_menu("level_overview_menu")


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "Reveal":
		animated_sprite_2d.play("Idle")
