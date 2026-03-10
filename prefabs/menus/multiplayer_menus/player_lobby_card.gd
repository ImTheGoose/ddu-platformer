extends HBoxContainer

@onready var player_icon :TextureRect = %player_icon
@onready var name_label :Label = %name_label
@onready var ping_label :Label = %ping_label
@onready var kick_button :Button = %kick_button

var assigned_player_id :int = -1

func _ready() -> void:
	kick_button.pressed.connect(_on_kick_pressed)
	
	if Lobby.is_lobby_lan():
		name_label.text = "Player: %s" % [assigned_player_id]

	if !multiplayer.is_server() or assigned_player_id == multiplayer.get_unique_id():
		kick_button.visible = false
		kick_button.disabled = true

func _on_kick_pressed() -> void:
	if !multiplayer.is_server():
		return
	
	multiplayer.multiplayer_peer.disconnect_peer(assigned_player_id)
