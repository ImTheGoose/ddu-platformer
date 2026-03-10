extends GameMenu

@onready var lobby_id_input :LineEdit = %LineEdit
@onready var join_button :Button = %join_button

func _ready() -> void:
	super()
	lobby_id_input.text_submitted.connect(_on_text_submitted)
	lobby_id_input.text_changed.connect(_on_text_changed)
	join_button.pressed.connect(_on_join_button_pressed)
	



func _on_text_changed(new_string: String) -> void:
	if new_string.contains(" ") or new_string == "":
		join_button.disabled = true
	else:
		join_button.disabled = false

func _on_text_submitted(new_string: String) -> void:
	_initiate_lobby_join()

func _on_join_button_pressed() -> void:
	_initiate_lobby_join()

func _initiate_lobby_join() -> void:
	if lobby_id_input.text.contains("."):
		Lobby.join_lan_server(lobby_id_input.text)
	else:
		Lobby.join_steam_lobby(int(lobby_id_input.text))

func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("multiplayer_select_menu")
