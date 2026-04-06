extends GameMenu

@onready var titel_label :Label = %titel
@onready var description_label :Label = %description

func _ready() -> void:
	super()
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_created.connect(_on_lobby_created)
	Lobby.connection_error.connect(_on_connection_error)

func _on_show() -> void:
	titel_label.text = "Connecting..."
	description_label.text = ""
	

func _on_cancel_button_pressed() -> void:
	Lobby.close_connection()
	MenuHandler.change_menu("main_menu")
	pass # Replace with function body.

func _on_connection_error(error_reason: String) -> void:
	titel_label.text = "Connection Failed"
	description_label.text = error_reason

func _on_lobby_created(connected: int, lobby_id: int) -> void:
	if connected == 1:
		return
	titel_label.text = "Connection Failed"
	description_label.text = "An error ooccured while creating a lobby."
	

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		return

	var fail_reason: String

	match response:
		Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
		Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
		Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
		Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
		Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
		Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
		Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
		Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
		Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
		Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
	
	titel_label.text = "Connection Failed"
	description_label.text = fail_reason
