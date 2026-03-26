extends Entity

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_collect :AudioStreamMP3 = preload("uid://cyi6b5lna87oj")

func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_multiplayer_authority():
			var money :Variant = DataManager.get_value("money")
			DataManager.set_value("money", money + 1) 
			Stats.add_recording_value(Stats.StatType.TOTAL_APPLES_COLLECTED, 1)
			rpc("show_collect")
			
@rpc("any_peer","call_local","reliable")
func show_collect() -> void:
	anim.play("Collect")
	AudioManager.play_global_sound(audio_collect, -9)


func _on_anim_finished() -> void:
	if multiplayer.is_server():
		rpc("disable")

func _on_reset() -> void:
	anim.play("Idle")
