extends Node

@export var hold_threshold: float = 0.5  # How long to hold before "gradual" kicks in
@export var max_speed: float = 20.0     # Buttons per second at full tilt
@export var deadzone: float = 0.3

var hold_time: float = 0.0
var move_timer: float = 0.0

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	# 1. Get stick strength
	var move_vec = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down"),
	)
	var strength = move_vec.length()

	# 2. Check if stick is being pushed
	if strength > deadzone:
		hold_time += delta
		
		# 3. Only act if we've passed the "Initial Tap" window
		if hold_time > hold_threshold:
			move_timer -= delta
			
			if move_timer <= 0:
				move_focus(move_vec)
				# Gradual speed: Higher strength = shorter timer
				move_timer = 1.0 / (max_speed * strength)
	else:
		# Reset when stick is released
		hold_time = 0.0
		move_timer = 0.0

func move_focus(dir: Vector2) -> void:
	var current_focus = get_viewport().gui_get_focus_owner()
	if not current_focus: return

	# Determine direction
	var side: Side
	if abs(dir.x) > abs(dir.y):
		side = SIDE_LEFT if dir.x < 0 else SIDE_RIGHT
	else:
		side = SIDE_TOP if dir.y < 0 else SIDE_BOTTOM
	
	var next_node = current_focus.find_valid_focus_neighbor(side)
	if next_node:
		next_node.grab_focus()
