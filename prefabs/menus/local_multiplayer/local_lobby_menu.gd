extends GameMenu

@onready var playerlist_container :VBoxContainer = %playerlist
@onready var start_game_button:Button = %start_game_button
@onready var player_amount_label :Label = %player_amount_label
@export var player_card_prefab :PackedScene = preload("uid://dkbiwh5gdqn8c")

func _ready() -> void:
	super()
	Lobby.local_player_removed.connect(_on_local_player_removed)
	

func _on_show() -> void:
	for child in playerlist_container.get_children():
		child.queue_free()
	_add_player_card(LocalMultiplayer.LocalID.PLAYER_ONE)
	
	#Lobby.created_player_infos.clear()
	#Lobby.add_player_info(LocalMultiplayer.LocalID.PLAYER_ONE)
	#_add_player_card(LocalMultiplayer.LocalID.PLAYER_ONE)
	#_clear_unused_in_playerlist()

func _on_local_player_removed() -> void:
	_update_ui_elements()
	_try_focus_grap()

func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	
	if not MenuHandler.is_menu_visible(menu_name):
		return

	if event is InputEventJoypadButton:
		if event.button_index != JOY_BUTTON_START:
			return
		
	for p_info:PlayerInfo in Lobby.created_player_infos.values():
		var input :InputConfig = p_info.get_input_from_event(event)
		if not input:
			continue
			
		if p_info.assigned_input_configs.size() <= 1:
			return
		
		if Lobby.get_lobby_size() >= 4:
			return
		
		p_info.remove_input(input)
		_create_player_from_input(input)
		return

func _create_player_from_input(input: InputConfig) -> void:
	var id: int = LocalMultiplayer.get_next_local_id()
	Lobby.add_player_info(id)
	_add_player_card(id)
	
	var player_info :PlayerInfo = Lobby.get_player_info(id)
	player_info.add_input(input)
	

func _clear_unused_in_playerlist() -> void:
	var used_ids :Array[int] = Lobby.created_player_infos.keys()
	for child in playerlist_container.get_children():
		if used_ids.has(child.assigned_peer_id):
			used_ids.erase(child.assigned_peer_id)
			continue
		else:
			child.queue_free()

func _add_player_card(peer_id: int) -> void:
	var player_card :Node = player_card_prefab.instantiate()
	player_card.assigned_peer_id = peer_id
	playerlist_container.add_child(player_card)
	_update_ui_elements()

func _update_ui_elements() -> void:
	_clear_unused_in_playerlist()
	player_amount_label.text = "Players: %s of 4" % Lobby.get_lobby_size()
	
	if multiplayer.is_server():
		start_game_button.visible = true
		start_game_button.disabled = Lobby.get_lobby_size() <= 1
	else:
		start_game_button.visible = false

func _on_quit_lobby_pressed() -> void:
	Lobby.close_connection()
	MenuHandler.change_menu("select_play_menu")
	_clear_unused_in_playerlist()

func _on_start_game_button_pressed() -> void:
	if !multiplayer.is_server():
		return
	
	GameManager.prepare_game()

func _on_customize_button_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu", true)


func _on_settings_button_pressed() -> void:
	MenuHandler.change_menu("settings_menu", true)
	
