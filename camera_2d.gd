extends Camera2D

@export var speed := 90
@export var safe_distance = 400
@onready var origin_position = position
var players :Array[CharacterBody2D]

const nudge_camera :bool = true

func _ready() -> void:
	GameManager.on_reset_game.connect(_reset_position)

func _reset_position():
	position = origin_position

func _process(delta: float) -> void:
	if players.size() > 0 && nudge_camera:
		for p in players:
			if !p:
				continue
			if p.global_position.y < global_position.y + safe_distance:
				var target_y = p.global_position.y - safe_distance
				var distance = abs(target_y - global_position.y)

				var m_speed = distance * distance * 0.0045
				
				global_position.y = move_toward(global_position.y, target_y, m_speed * delta)

	
	
	if GameManager.is_game_running() && !GameManager.is_game_paused():
		var speed_scale = GameManager.get_difficulty_value("camera_speed")
		position.y -= speed_scale * speed * delta

func _on_player_follow_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if !players.has(body):
			players.append(body)
	pass # Replace with function body.
