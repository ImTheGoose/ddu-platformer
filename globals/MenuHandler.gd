extends Node

signal request_back_from_menu()
signal changed_menu_visibillity(target: String, isVisible: bool)
signal changed_seperator_visibillity(isVisible: bool)
signal changed_blackout_visibillity(isVisible: bool)
signal changed_game_visibillity(isVisible: bool)
signal game_is_covered()

var background_is_visible :bool = false
var game_is_visible :bool = false

var registered_menu_names :Array[String]
var visible_menu_names :Array[String] = []

var previous_menu :String

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	changed_seperator_visibillity.connect(_background_visible_changed)
	changed_game_visibillity.connect(_on_game_visible_changed)

func register_menu_name(menu_name : String) -> void:
	registered_menu_names.append(menu_name)
	visible_menu_names.append(menu_name)

func show_background_seperator() -> void:
	changed_seperator_visibillity.emit(true)
	
func hide_background_seperator() -> void:
	changed_seperator_visibillity.emit(false)

func _background_visible_changed(isVisible: bool) -> void:
	background_is_visible = isVisible

func _on_game_visible_changed(isVisible: bool) -> void:
	game_is_visible = isVisible

func is_menu_visible(menu_name : String) -> bool:
	return visible_menu_names.has(menu_name)

@rpc("authority","call_local","reliable")
func hide_all_menus() -> void:
	for menu_name in registered_menu_names:
		hide_menu(menu_name)

func hide_menu(menu_name : String) -> void:
	while visible_menu_names.has(menu_name):
		visible_menu_names.erase(menu_name)
	changed_menu_visibillity.emit(menu_name, false)

func show_menu(menu_name : String) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible_menu_names.append(menu_name)
	changed_menu_visibillity.emit(menu_name, true)

@rpc("authority","call_local","reliable")
func hide_game() -> void:
	changed_game_visibillity.emit(false)

@rpc("authority","call_local","reliable")
func show_game() -> void:
	changed_game_visibillity.emit(true)
	
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
		request_back_from_menu.emit()

func change_menu(menu_name : String) -> void:
	if visible_menu_names.size() > 0:
		previous_menu = visible_menu_names[0]

	hide_all_menus()
	show_menu(menu_name)
