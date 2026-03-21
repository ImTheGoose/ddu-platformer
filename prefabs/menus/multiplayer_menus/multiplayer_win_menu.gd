extends GameMenu

@onready var conclusion_label: Label = $conclusion_label
@export var leaderboard_card: PackedScene = preload("uid://c7dgnmx5qr2ml")
@onready var player_leaderboard: VBoxContainer = %player_leaderboard

@onready var play_again_button: Button = %play_again_button
@onready var return_to_lobby: Button = %return_to_lobby
@onready var quit_to_main: Button = %quit_to_main

func _ready() -> void:
	super()
	GameManager.game_scores_changed.connect(_on_scores_changed)
	clear_leaderboard()

func _on_scores_changed() -> void:
	call_deferred("update_board")

func _on_show() -> void:
	clear_leaderboard()
	build_leaderboard()
	update_board()

	if multiplayer.is_server():
		play_again_button.visible = true
		play_again_button.disabled = false
		return_to_lobby.visible = true
		return_to_lobby.disabled = false
		quit_to_main.visible = false
		quit_to_main.disabled = true
	else:
		play_again_button.visible = false
		play_again_button.disabled = true
		return_to_lobby.visible = false
		return_to_lobby.disabled = true
		quit_to_main.visible = true
		quit_to_main.disabled = false


func update_board() -> void:
	sort_leaderboard()
	if GameManager.get_placement(multiplayer.get_unique_id()) == 1:
		conclusion_label.text = "Game Winner"
	else:
		conclusion_label.text = "Loser"


func build_leaderboard() -> void:
	var peer_list :PackedInt32Array = multiplayer.get_peers()
	peer_list.append(multiplayer.get_unique_id())
	
	for peer: int in peer_list:
		var card :Control = leaderboard_card.instantiate()
		card.assigned_peer_id = peer
		player_leaderboard.add_child(card)

func sort_leaderboard() -> void:
	var sorted_cards :Dictionary[int, Node] = {}
	for card in player_leaderboard.get_children():
		var peer :int = card.assigned_peer_id
		var placement :int = GameManager.get_match_placement(peer) - 1
		if placement > player_leaderboard.get_child_count():
			continue
		else:
			sorted_cards.set(placement, card)
	
	for index: int in sorted_cards.keys():
		player_leaderboard.move_child(sorted_cards[index], index)
	return

func clear_leaderboard() -> void:
	for child in player_leaderboard.get_children():
		child.queue_free()


func _on_play_again_button_pressed() -> void:
	GameManager.prepare_game()

func _on_return_to_lobby_pressed() -> void:
	GameManager.return_to_lobby()

func _on_settings_button_pressed() -> void:
	MenuHandler.change_menu("settings_menu", true)


func _on_customize_button_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu", true)


func _on_quit_to_main_pressed() -> void:
	GameManager.quit_to_main()
