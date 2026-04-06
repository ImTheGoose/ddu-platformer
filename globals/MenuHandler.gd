extends Node

signal changed_seperator_visibillity(isVisible: bool)
signal changed_blackout_visibillity(isVisible: bool)
signal changed_game_visibillity(isVisible: bool)
signal game_is_covered()

var background_is_visible :bool = false
var game_is_visible :bool = false

var registered_menus :Dictionary[String, GameMenu] = {}
var visible_menus :Dictionary[String, GameMenu] = {}

var previous_menu :String

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	changed_seperator_visibillity.connect(_background_visible_changed)
	changed_game_visibillity.connect(_on_game_visible_changed)

func register_menu(menu_name : String, root_node : Control) -> void:
	registered_menus.set(menu_name, root_node)
	visible_menus.set(menu_name, root_node)

func show_background_seperator() -> void:
	changed_seperator_visibillity.emit(true)
	
func hide_background_seperator() -> void:
	changed_seperator_visibillity.emit(false)

func _background_visible_changed(isVisible: bool) -> void:
	background_is_visible = isVisible

func _on_game_visible_changed(isVisible: bool) -> void:
	game_is_visible = isVisible

func is_menu_visible(menu_name : String) -> bool:
	return visible_menus.has(menu_name)

@rpc("authority","call_local","reliable")
func hide_all_menus() -> void:
	for menu_name in visible_menus.keys():
		hide_menu(menu_name)

func hide_menu(menu_name : String) -> void:
	if visible_menus.has(menu_name):
		var root_node :GameMenu = visible_menus.get(menu_name)
		root_node.hide_menu()
		visible_menus.erase(menu_name)

func show_menu(menu_name : String) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if registered_menus.has(menu_name):
		var root_node :GameMenu = registered_menus.get(menu_name)
		root_node.show_menu()
		visible_menus.set(menu_name, root_node)
	else:
		print("menu: %s doesnt exist in regestry" % menu_name)


@rpc("authority","call_local","reliable")
func hide_game() -> void:
	changed_game_visibillity.emit(false)

@rpc("authority","call_local","reliable")
func show_game() -> void:
	changed_game_visibillity.emit(true)
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		Steamworks.set_rich_presense("#PlayingSingleplayer")
	else:
		Steamworks.set_rich_presense("#InMatch")
	
@rpc("authority","call_local","reliable")
func show_blackout() -> void:
	changed_blackout_visibillity.emit(true)

@rpc("authority","call_local","reliable")
func hide_blackout() -> void:
	changed_blackout_visibillity.emit(false)

func get_previous_menu() -> String:
	return previous_menu

func is_game_visible() -> bool:
	return game_is_visible

func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel") && event.is_pressed():
		if visible_menus.size() > 0:
			var root_node :GameMenu = visible_menus.values()[0]
			root_node.go_back()

@rpc("authority","call_local","reliable")
func change_menu(menu_name : String, log_as_previous: bool = false) -> void:
	if visible_menus.size() > 0 && log_as_previous:
		previous_menu = visible_menus.keys()[0]
	
	hide_all_menus()
	show_menu(menu_name)
