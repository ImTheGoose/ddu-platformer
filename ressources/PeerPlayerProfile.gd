extends PlayerInfo

class_name PeerPlayerInfo 

@export var STEAM_ID :int = -1

func _init(assigned_peer_id: int) -> void:
	super(assigned_peer_id)
	
	add_input(load("uid://cwxlh4yqekm8r"))
	
	Steam.persona_state_change.connect(_on_persona_state_change)
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Lobby.peer_linked_to_steam.connect(_on_peer_linked_to_steam)
	Lobby.peer_cosmetic_updated.connect(_on_peer_cosmetic_updated)
	
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
	Lobby.request_data_from_peer(PEER_ID, Lobby.DataRequestType.COSMETIC_SKIN)
	Lobby.request_data_from_peer(PEER_ID, Lobby.DataRequestType.COSMETIC_OUTLINE)

func _on_persona_state_change(steam_id: int, flags: int) -> void:
	if steam_id != STEAM_ID:
		return
	
	DISPLAY_NAME = Steam.getFriendPersonaName(STEAM_ID)

func _on_avatar_loaded(avatar_id: int, avatar_size: int, avatar_buffer: Array) -> void:
	if avatar_id != STEAM_ID:
		return

	var avatar_image :Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	avatar_image.resize(128, 128)
	AVATAR_TEXTURE = ImageTexture.create_from_image(avatar_image)

func _on_peer_cosmetic_updated(peer_id: int, data_type: int, data: Array[Variant]) -> void:
	if peer_id != PEER_ID:
		return
	
	match data_type:
		Lobby.DataRequestType.COSMETIC_SKIN:
			SELECTED_SKIN_NAME = data[0]
		Lobby.DataRequestType.COSMETIC_OUTLINE:
			SELECTED_OUTLINE_HEX = data[0]
	
	cosmetics_changed.emit()
