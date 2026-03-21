extends GameMenu


@export var leaderboard_card: PackedScene = preload("uid://c2sykb4hpg0u7")
@onready var player_leaderboard: VBoxContainer = %player_leaderboard
@onready var round_label: Label = %round_label


@onready var next_round_button: Button = %next_round_button
@onready var return_to_lobby: Button = %return_to_lobby
@onready var quit_to_main: Button = %quit_to_main

func _ready() -> void:
	super()
	GameManager.game_scores_changed.connect(_on_scores_changed)
	clear_leaderboard()

func _on_scores_changed() -> void:
	update_board()

func _on_show() -> void:
	clear_leaderboard()
	build_leaderboard()
	update_board()
	
	if multiplayer.is_server():
		next_round_button.visible = true
		next_round_button.disabled = false
		return_to_lobby.visible = true
		return_to_lobby.disabled = false
		quit_to_main.visible = false
		quit_to_main.disabled = true
	else:
		next_round_button.visible = false
		next_round_button.disabled = true
		return_to_lobby.visible = false
		return_to_lobby.disabled = true
		quit_to_main.visible = true
		quit_to_main.disabled = false

func update_board() -> void:
	sort_leaderboard()
	if GameManager.get_placement(multiplayer.get_unique_id()) == 1:
		round_label.text = "Round Won"
	else:
		round_label.text = "Round Lost"


func build_leaderboard() -> void:
	var peer_list :PackedInt32Array = multiplayer.get_peers()
	peer_list.append(multiplayer.get_unique_id())
	
	for peer: int in peer_list:
		var card :Control = leaderboard_card.instantiate()
		card.assigned_peer_id = peer
		player_leaderboard.add_child(card)

func sort_leaderboard() -> void:
	for card in player_leaderboard.get_children():
		var peer :int = card.assigned_peer_id
		var placement :int = GameManager.get_placement(peer) - 1
		if placement > player_leaderboard.get_child_count():
			return
		player_leaderboard.move_child(card, placement)
	return

func clear_leaderboard() -> void:
	for child in player_leaderboard.get_children():
		child.queue_free()

func _on_next_round_button_pressed() -> void:
	GameManager.next_round()

func _on_return_to_lobby_pressed() -> void:
	GameManager.return_to_lobby()

func _on_settings_button_pressed() -> void:
	MenuHandler.change_menu("settings_menu", true)


func _on_customize_button_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu", true)


func _on_quit_to_main_pressed() -> void:
	GameManager.quit_to_main()
