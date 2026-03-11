extends HBoxContainer

@onready var player_icon :TextureRect = %player_icon
@onready var name_label :Label = %name_label
@onready var ping_label :Label = %ping_label
@onready var kick_button :Button = %kick_button

var assigned_peer_id :int = -1
var assigned_player_info :PlayerInfo

func _ready() -> void:
	kick_button.pressed.connect(_on_kick_pressed)
	assigned_player_info = Lobby.get_player_info(assigned_peer_id)
	
	assigned_player_info.persona_name_changed.connect(_on_persona_name_changed)
	assigned_player_info.avatar_image_changed.connect(_on_avatar_changed)
	
	name_label.text = assigned_player_info.DISPLAY_NAME

	if !multiplayer.is_server() or assigned_player_info.PEER_ID == multiplayer.get_unique_id():
		kick_button.visible = false
		kick_button.disabled = true

func _on_avatar_changed() -> void:
	player_icon.texture = assigned_player_info.get_avatar_texture(128)

func _on_persona_name_changed(new_name: String) -> void:
	name_label.text = new_name	

func _on_kick_pressed() -> void:
	if !multiplayer.is_server():
		return
	
	Lobby.kick_peer(assigned_player_info.PEER_ID)
