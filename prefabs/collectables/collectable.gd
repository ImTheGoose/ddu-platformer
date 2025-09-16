extends Area2D

@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		anim.play("Collect")
		pass

func _on_anim_finished():
	self.queue_free()
	
