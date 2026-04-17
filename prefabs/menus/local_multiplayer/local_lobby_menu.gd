extends GameMenu

@onready var playerlist_container :VBoxContainer = %playerlist
@onready var start_game_button:Button = %start_game_button
@onready var player_amount_label :Label = %player_amount_label
@export var player_card_prefab :PackedScene = preload("uid://dkbiwh5gdqn8c")

func _ready() -> void:
	super()

func _on_show() -> void:
	Lobby.created_player_infos.clear()
	Lobby.add_player_info(LocalMultiplayer.LocalID.PLAYER_ONE)
	_add_player_card(LocalMultiplayer.LocalID.PLAYER_ONE)
	_clear_unused_in_playerlist()
	
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
	
