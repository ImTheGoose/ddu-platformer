extends Entity
@export_group("Nodes")
@export var anim_player :AnimationPlayer
@export var health_component :HealthComponent
@export var hitbox_component :HitBoxComponent
@export var sprite_component :EnemySpriteComponent
@export_range(0, 10.0,0.1) var seconds_between_states :float = 3.0
var seconds_since_state_change :float = 0.0

func _ready() -> void:
	if sprite_component:
		sprite_component.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if sprite_component.animation.contains("App"):
		sprite_component.play("Moving")
		hitbox_component.enable_hitbox()
		return
	
	if sprite_component.animation.contains("Dis"):
		sprite_component.play("Moving")
		return
	
	return

func is_ghost_hidden() -> bool:
	return !modulate == Color.WHITE

func _process(delta: float) -> void:
	if health_component:
		if health_component.is_dead():
			return
	
	seconds_since_state_change += delta
	
	if seconds_since_state_change > seconds_between_states:
		seconds_since_state_change = 0.0
		if is_ghost_hidden():
			anim_player.play("Appear")
		else:
			anim_player.play("Disappear")
			hitbox_component.disable_hitbox()
		

func _on_reset() -> void:
	modulate = Color.WHITE
	anim_player.play("RESET")
	sprite_component.play("Moving")
