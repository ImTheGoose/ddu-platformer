extends Node

class_name AttackComponent 

@export var player_detecting_component :PlayerDetectionComponent
@export var movement_component :MovementComponent
@export var sprite_component :EnemySpriteComponent
@export var attack_frame :int = 7
@export_range(0,5,0.1) var seconds_between_attacks :float = 1.2
var seconds_since_attack :float = 0.0

signal attack_initiated
signal attack_fired
signal attack_finished

func _ready() -> void:
	if sprite_component:
		sprite_component.frame_changed.connect(_on_frame_changed)


func _process(delta: float) -> void:
	seconds_since_attack += delta
	
	if player_detecting_component.is_detecting_player():
		attempt_attack()

func _on_frame_changed() -> void:
	if not sprite_component.animation.contains("Att"):
		return
	
	if sprite_component.frame == sprite_component.sprite_frames.get_frame_count(sprite_component.animation) - 1:
		attack_finished.emit()
		if movement_component:
			movement_component.resume_movement()
	
	elif sprite_component.frame == attack_frame:
		_fire_attack()

func is_attacking() -> bool:
	return sprite_component.animation.contains("Att") && sprite_component.is_playing()

func attempt_attack() -> void:
	if seconds_since_attack < seconds_between_attacks:
		return
	_initiate_attack()


func _initiate_attack() -> void:
	seconds_since_attack = 0.0
	attack_initiated.emit()
	sprite_component.play("Attack")
	if movement_component:
		movement_component.block_movement()

func _fire_attack() -> void:
	attack_fired.emit()
