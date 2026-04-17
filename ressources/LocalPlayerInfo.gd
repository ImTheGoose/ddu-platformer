extends PlayerInfo

class_name LocalPlayerInfo 

func _init(assigned_peer_id: int) -> void:
	super(assigned_peer_id)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	peer_id_changed.connect(_on_peer_id_changed)
	
	if assigned_peer_id == LocalMultiplayer.LocalID.PLAYER_ONE:
		add_input(load("uid://ckd85umeubwsw")) #WASD movement

		add_input(load("uid://b050s1jybuwad")) #ARROW movement
		
		for id in Input.get_connected_joypads():
			var input :InputConfig = InputConfig.new()
			input.joypad_id = id
			add_input(input)
	_refresh_visuals()

func _on_peer_id_changed() -> void:
	_refresh_visuals()

func _refresh_visuals() -> void:
	match PEER_ID:
		LocalMultiplayer.LocalID.PLAYER_ONE:
			DISPLAY_NAME = "Player 1"
		LocalMultiplayer.LocalID.PLAYER_TWO:
			DISPLAY_NAME = "Player 2"
		LocalMultiplayer.LocalID.PLAYER_THREE:
			DISPLAY_NAME = "Player 3"
		LocalMultiplayer.LocalID.PLAYER_FOUR:
			DISPLAY_NAME = "Player 4"
		_:
			DISPLAY_NAME = "ERROR"

func _on_joy_connection_changed(id: int, connected: bool) -> void:
	if connected:
		if PEER_ID == LocalMultiplayer.LocalID.PLAYER_ONE:
			for input: InputConfig in assigned_input_configs:
				if input.joypad_id == id:
					return
			
			var input :InputConfig = InputConfig.new()
			input.joypad_id = id
			add_input(input)
	else:
		var new_assinged_inputs :Array[InputConfig]
		for input: InputConfig in assigned_input_configs:
			if input.joypad_id != id:
				new_assinged_inputs.append(input)
		
		assigned_input_configs = new_assinged_inputs

func get_input_icons_bbcode() -> String:
	var icon_string :String = ""
	for input_config: InputConfig in assigned_input_configs:
		icon_string += input_config.get_icon_bbcode()
	return icon_string
