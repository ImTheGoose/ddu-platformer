extends Resource

class_name PlayerInfo

@export var STEAM_ID :int = -1
@export var PEER_ID :int = -1
@export var AVATAR_IMAGE :Image:
	set(value):
		AVATAR_IMAGE = value
		avatar_image_changed.emit()
		
@export var DISPLAY_NAME: String = "lan_placeholder":
	set(value):
		DISPLAY_NAME = value
		persona_name_changed.emit(value)

signal persona_name_changed(new_name: String)
signal avatar_image_changed()

func _init(assigned_peer_id: int) -> void:
	PEER_ID = assigned_peer_id
	
	Steam.persona_state_change.connect(_on_persona_state_change)
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Lobby.peer_linked_to_steam.connect(_on_peer_linked_to_steam)
	
	if Lobby.is_lobby_lan():
		return
	
	STEAM_ID = Lobby.get_steam_id_from_peer_id(PEER_ID)
	Steam.getPlayerAvatar(2, STEAM_ID)
	DISPLAY_NAME = Steam.getFriendPersonaName(STEAM_ID)

func _on_peer_linked_to_steam(peer_id: int, steam_id: int) -> void:
	if peer_id != PEER_ID or steam_id < 1:
		return
	
	STEAM_ID = steam_id
	Steam.getPlayerAvatar(2, STEAM_ID)
	DISPLAY_NAME = Steam.getFriendPersonaName(STEAM_ID)

func _on_persona_state_change(steam_id: int, flags: int) -> void:
	if steam_id != STEAM_ID:
		return
	
	DISPLAY_NAME = Steam.getFriendPersonaName(STEAM_ID)

func _on_avatar_loaded(avatar_id: int, avatar_size: int, avatar_buffer: Array) -> void:
	if avatar_id != STEAM_ID:
		return

	AVATAR_IMAGE = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

func get_avatar_texture(texture_size: int) -> ImageTexture:
	var img :Image = AVATAR_IMAGE.duplicate()
	img.resize(texture_size, texture_size)
	return ImageTexture.create_from_image(img)
