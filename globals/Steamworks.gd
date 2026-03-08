extends Node

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	get_tree().root.ready.connect(_on_tree_ready)
	
func _on_tree_ready() -> void:
	var init_response :Dictionary = Steam.get_steam_init_result() # Tjekker om der var fejl under steam hook.
	if init_response.is_empty():
		await get_tree().process_frame
		_on_tree_ready()
		return

	if init_response.status != Steam.STEAM_API_INIT_RESULT_OK:
		MenuHandler.change_menu("steam_error_popup")
