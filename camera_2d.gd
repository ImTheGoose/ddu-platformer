extends Camera2D

@export var speed := 90
@export var safe_distance = 400
@onready var origin_position = position

const nudge_camera :bool = true

func _ready() -> void:
	GameManager.on_reset_game.connect(_reset_position)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	var rect = get_viewport_rect()
	var boundary_size = rect.size - Vector2(1920, 1080)
	var pos_offset = boundary_size / 2
	offset.x = -pos_offset.x

func _reset_position():
	position = origin_position

func _process(delta: float) -> void:
	var players := get_tree().get_nodes_in_group("Players")
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
