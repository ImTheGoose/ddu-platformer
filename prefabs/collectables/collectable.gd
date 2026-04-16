extends Entity

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
@export var collect_sounds :Dictionary[AudioStream, float]
var is_collected :bool = false

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_multiplayer_authority():
			if is_collected:
				return
			
			var money :Variant = DataManager.get_value("money")
			DataManager.set_value("money", money + 1) 
			Stats.add_recording_value(Stats.StatType.TOTAL_APPLES_COLLECTED, 1)
			rpc("show_collect")
			
@rpc("any_peer","call_local","reliable")
func show_collect() -> void:
	is_collected = true
	anim.play("Collect")
	Audio.play_random(collect_sounds, randf_range(0.6, 1))

func _on_animation_finished() -> void:
	if is_collected:
		visible = false

func _on_reset() -> void:
	is_collected = false
	anim.play("Idle")
	anim.frame = 0
