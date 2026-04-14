extends Camera2D

@export var speed :int = 25
@export var safe_distance :int = 90
@onready var origin_position :Vector2 = position
@export_group("Spring Settings")
@export var stiffness := 250.0      # How "tight" the spring is (higher = faster snaps)
@export var damping := 15.0        # How "bouncy" it is (lower = more 'boing', higher = less)

@export_group("Jitter Settings")
@export var jitter_decay := 10.0    # Random vibration decay
@export var max_jitter := 40.0

var jitter_energy := 0.0    # Current vibration strength
var displacement := Vector2.ZERO # The spring's current position
var velocity := Vector2.ZERO     # The spring's current speed

var nudge_camera :bool = true

func _ready() -> void:
	GameManager.client_reset.connect(_reset_position)
	GameManager.add_camera_shake.connect(add_shake)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_J:
					add_shake(1.5, Vector2.RIGHT, 10)
				KEY_H:
					add_shake(1.5, Vector2.LEFT, 10)
				KEY_U:
					add_shake(1.5, Vector2.UP, 10)
				KEY_N:
					add_shake(1.5, Vector2.DOWN, 10)

func _reset_position() -> void:
	position = origin_position
	offset = Vector2.ZERO


func _process(delta: float) -> void:
	# 1. Physics: The Spring Equation (F = -kx - cv)
	# This pulls the camera back to center and adds "friction" (damping)
	var force = -stiffness * displacement - damping * velocity
	velocity += force * delta
	displacement += velocity * delta
	
	# 2. Random Jitter (Exponential decay is fine here for the "fuzz")
	jitter_energy = jitter_energy * exp(-jitter_decay * delta)
	
	# 3. Apply the results
	if displacement.length() > 0.1 or jitter_energy > 0.1:
		var random_offset = Vector2(
			randf_range(-jitter_energy, jitter_energy),
			randf_range(-jitter_energy, jitter_energy)
		)
		offset = displacement + random_offset
	else:
		offset = Vector2.ZERO
		velocity = Vector2.ZERO
		displacement = Vector2.ZERO
	
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

## strength: Chaos/vibration
## direction: The direction of the hit
## power: The physical "shove" into the spring
func add_shake(strength: float, direction: Vector2 = Vector2.ZERO, power: float = 0.0) -> void:
	# Add vibration
	jitter_energy = min(jitter_energy + strength, max_jitter)
	
	# Instead of just moving the camera, we add to the velocity
	# This makes the "impact" feel like a physical hit
	if direction != Vector2.ZERO:
		velocity += direction.normalized() * power * 10
