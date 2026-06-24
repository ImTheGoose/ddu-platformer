extends VBoxContainer

@onready var playerlist_container :VBoxContainer = %playerlist
@onready var diff_label: Label = %difficulty_label
@onready var diff_option: OptionButton = %difficulty_option
@onready var rounds_label: Label = %rounds_label
@onready var rounds_option: OptionButton = %rounds_option
@onready var collission_label: Label = %collission_label
@onready var collission_option: OptionButton = %collission_option
@onready var gamemode_label: Label = %gamemode_label
@onready var gamemode_option: OptionButton = %gamemode_option
@onready var map_collection_label: Label = %map_collection_label
@onready var map_collection_option: OptionButton = %map_collection_option
@onready var intermission_label: Label = %intermission_label
@onready var intermission_option: OptionButton = %intermission_option

func _ready() -> void:
	GameManager.game_settings_changed.connect(_on_game_settings_changed)
	multiplayer.connected_to_server.connect(refresh_settings)
	
	playerlist_container.child_order_changed.connect(_refresh_focus)
	
	diff_option.item_selected.connect(_on_difficulty_selected)
	rounds_option.item_selected.connect(_on_rounds_selected)
	gamemode_option.item_selected.connect(_on_gamemode_selected)
	collission_option.item_selected.connect(_on_collissions_selected)
	map_collection_option.item_selected.connect(_on_map_collection_selected)
	intermission_option.item_selected.connect(_on_intermission_selected)
	_initialise_collection_dropdown()
	
	refresh_settings()

func _initialise_collection_dropdown() -> void:
	map_collection_option.clear()
	for collection:String in MapFile.CollectionType.keys():
		if not OS.is_debug_build():
			if not MapFile.VISIBLE_COLLECTIONS_IN_RELEASE.has(MapFile.CollectionType[collection]):
				continue
		map_collection_option.add_item(collection.capitalize(), MapFile.CollectionType[collection])
	
	map_collection_option.selected = map_collection_option.get_item_index(GameManager.get_map_collection())

func _refresh_focus() -> void:
	if not multiplayer.is_server():
		return
	var player_cards :Array[Node] = playerlist_container.get_children()
	player_cards.pop_front()
	if player_cards.size() > 0:
		var kick_button :Button = player_cards.get(0).kick_button
		diff_option.focus_neighbor_left = kick_button.get_path()
		rounds_option.focus_neighbor_left = kick_button.get_path()
		collission_option.focus_neighbor_left = kick_button.get_path()
		gamemode_option.focus_neighbor_left = kick_button.get_path()
		map_collection_option.focus_neighbor_left = kick_button.get_path()
		intermission_option.focus_neighbor_left = kick_button.get_path()
		kick_button.focus_neighbor_right = rounds_option.get_path()
		
		if player_cards.size() > 1:
			kick_button = player_cards.get(1).kick_button
			collission_option.focus_neighbor_left = kick_button.get_path()
			gamemode_option.focus_neighbor_left = kick_button.get_path()
			map_collection_option.focus_neighbor_left = kick_button.get_path()
			kick_button.focus_neighbor_right = gamemode_option.get_path()
			intermission_option.focus_neighbor_left = kick_button.get_path()
		if player_cards.size() > 2:
			kick_button = player_cards.get(2).kick_button
			map_collection_option.focus_neighbor_left = player_cards.get(2).kick_button.get_path()
			kick_button.focus_neighbor_right = map_collection_option.get_path()
			
		
	else:
		diff_option.focus_neighbor_left = NodePath("")
		rounds_option.focus_neighbor_left = NodePath("")
		collission_option.focus_neighbor_left = NodePath("")
		gamemode_option.focus_neighbor_left = NodePath("")
		map_collection_option.focus_neighbor_left = NodePath("")
		intermission_option.focus_neighbor_left = NodePath("")

func _on_collissions_selected(index: int) -> void:
	if index == 0:
		GameManager.set_collisions_enabled(false)
	else:
		GameManager.set_collisions_enabled(true)
	
	GameManager.sync_settings_to_peers()

func _on_map_collection_selected(index: int) -> void:
	GameManager.set_map_collection(map_collection_option.get_item_id(index))
	GameManager.sync_settings_to_peers()

func _on_gamemode_selected(index: int) -> void:
	GameManager.set_gamemode(index)
	GameManager.sync_settings_to_peers()

func _on_rounds_selected(index: int) -> void:
	GameManager.set_total_rounds(rounds_option.get_item_id(index))
	GameManager.sync_settings_to_peers()

func _on_difficulty_selected(index: int) -> void:
	Difficulty.set_difficulty(index)
	GameManager.sync_settings_to_peers()

func _on_intermission_selected(index: int) -> void:
	GameManager.set_intermission(index)
	GameManager.sync_settings_to_peers()

func _on_game_settings_changed() -> void:
	refresh_settings()

func refresh_settings() -> void:
	if multiplayer.is_server():		
		diff_option.visible = true
		rounds_option.visible = true
		collission_option.visible = true
		gamemode_option.visible = true
		map_collection_option.visible = true
		diff_label.text = "Difficulty: "
		rounds_label.text = "Total Rounds: "
		collission_label.text = "Collissions: "
		gamemode_label.text = "Gamemode: "
		map_collection_label.text = "Collection: "
		intermission_label.text = "Leaderboard: "
		diff_option.selected = Difficulty.get_difficulty()
		
		rounds_option.selected = rounds_option.get_item_index(GameManager.get_total_rounds())
		map_collection_option.selected = map_collection_option.get_item_index(GameManager.get_map_collection())
		
		
	else:
		diff_option.visible = false
		rounds_option.visible = false
		collission_option.visible = false
		gamemode_option.visible = false
		map_collection_option.visible = false
		intermission_option.visible = false
		diff_label.text = "Difficulty: %s" % diff_option.get_item_text(Difficulty.get_difficulty())
		rounds_label.text = "Total Rounds: %s" % rounds_option.get_item_text(rounds_option.get_item_index(GameManager.get_total_rounds()))
		if GameManager.is_collissions_enabled():
			collission_label.text = "Collissions: enabled"
		else:
			collission_label.text = "Collissions: disabled"
		gamemode_label.text = "Gamemode: %s" % gamemode_option.get_item_text(GameManager.get_gamemode())
		map_collection_label.text = "Collection: %s" % map_collection_option.get_item_text(map_collection_option.get_item_index(GameManager.get_map_collection()))
		intermission_label.text = "Leaderboard: %s" % intermission_option.get_item_text(GameManager.get_intermission())
		
	return
