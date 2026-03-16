extends Camera2D

@export var speed :int = 90
@export var safe_distance :int = 400
@onready var origin_position :Vector2 = position

const nudge_camera :bool = true

func _ready() -> void:
	GameManager.client_reset.connect(_reset_position)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	var rect :Rect2 = get_viewport_rect()
	var boundary_size :Vector2 = rect.size - Vector2(1920, 1080)
	var pos_offset :Vector2 = boundary_size / 2
	offset.x = -pos_offset.x

func _reset_position() -> void:
	position = origin_position

func _process(delta: float) -> void:
	var players :Array[Node] = get_tree().get_nodes_in_group("Players")
	if players.size() > 0 && nudge_camera:
		for p in players:
			if !p or p is not CharacterBody2D:
				continue
			if p.global_position.y < global_position.y + safe_distance:
				var target_y :float = p.global_position.y - safe_distance
				var distance :float = abs(target_y - global_position.y)

				var m_speed :float = distance * distance * 0.0045
				
				global_position.y = move_toward(global_position.y, target_y, m_speed * delta)

	
	
	if GameManager.is_game_running() && !GameManager.is_game_paused():
		var speed_scale :Variant = GameManager.get_difficulty_value("camera_speed")
		position.y -= speed_scale * speed * delta
