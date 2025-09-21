extends Camera2D

@export var speed := 90
@export var safe_distance = 300
@onready var origin_position = position
var player :CharacterBody2D

func _ready() -> void:
	GameManager.on_reset_game.connect(_reset_position)

func _reset_position():
	position = origin_position

func _process(delta: float) -> void:
	if player:
		global_position.y = lerp(global_position.y, player.global_position.y - safe_distance, delta)
	
	
	if GameManager.is_game_running() && !GameManager.is_game_paused():
		var speed_scale = GameManager.get_difficulty_value("camera_speed")
		position.y -= speed_scale * speed * delta

func _on_player_follow_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player = body
	pass # Replace with function body.


func _on_player_follow_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.global_position.y > global_position.y:
			player = null
	pass # Replace with function body.
