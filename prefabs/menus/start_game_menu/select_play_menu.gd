extends GameMenu

@onready var online_multiplayer_button :Button = %online_multiplayer

func _ready() -> void:
	super()
	online_multiplayer_button.disabled = !Steam.loggedOn()
	Steam.steam_server_connected.connect(_on_steam_server_connected)
	Steam.steam_server_disconnected.connect(_on_steam_server_disconnected)

func _on_steam_server_disconnected(result: int) -> void:
	online_multiplayer_button.disabled = !Steam.loggedOn()

func _on_steam_server_connected() -> void:
	online_multiplayer_button.disabled = !Steam.loggedOn()
 
func _on_singleplayer_pressed() -> void:
	MenuHandler.change_menu("start_game_menu")
	pass # Replace with function body.


func _on_local_multiplayer_pressed() -> void:
	pass # Replace with function body.


func _on_online_multiplayer_pressed() -> void:
	MenuHandler.change_menu("multiplayer_select_menu")
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("main_menu")
	pass # Replace with function body.
