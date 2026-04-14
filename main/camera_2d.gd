extends Camera2D

@export var speed :int = 25
@export var safe_distance :int = 90
@onready var origin_position :Vector2 = position

var nudge_camera :bool = true

func _ready() -> void:
	GameManager.client_reset.connect(_reset_position)
	GameManager.add_camera_trauma.connect(add_trauma)
	noise.seed = randi()

func _reset_position() -> void:
	position = origin_position
	offset = Vector2.ZERO
	trauma = 0.0

func _process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
  #optional
	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		lerp(offset.x,0.0,1)
		lerp(offset.y,0.0,1)
		lerp(rotation,0.0,1)
	
	if !GameManager.is_game_running():
		return
	
	nudge_camera = GameManager.get_gamemode() == GameManager.Gamemode.GAMEMODE_STANDARD
	var players :Array[Node] = get_tree().get_nodes_in_group("Players")
	if players.size() > 0 && nudge_camera:
		for p in players:
			if !p or p is not Player:
				continue
			if p.global_position.y < global_position.y + safe_distance:
				var target_y :float = p.global_position.y - safe_distance
				var distance :float = abs(target_y - global_position.y)

				var m_speed :float = distance * distance * 0.0045
				
				global_position.y = move_toward(global_position.y, target_y, m_speed * delta)

	
	
	if !GameManager.is_game_paused():
		var speed_scale :Variant = Difficulty.get_setting(Difficulty.Settings.CAMERA_SPEED_SCALE)
		position.y -= speed_scale * speed * delta

@export var decay := 0.8 #How quickly shaking will stop [0,1].
@export var max_offset := Vector2(100,75) #Maximum displacement in pixels.
@export var max_roll := 0.1 #Maximum rotation in radians (use sparingly).
@export var noise : FastNoiseLite #The source of random values.

var noise_y :float = 0.0 #Value used to move through the noise

var trauma := 0.0 #Current shake strength
var trauma_pwr := 1.9 #Trauma exponent. Use [2,3]

func add_trauma(amount : float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void: 
	var amt :float = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(noise.seed*2,noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(noise.seed*3,noise_y)
