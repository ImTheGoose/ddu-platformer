extends Node

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	get_tree().root.ready.connect(_on_tree_ready)
	Steam.initRelayNetworkAccess()

func _process(delta: float) -> void:
	Steam.run_callbacks()
	
func _on_tree_ready() -> void:
	var init_response :Dictionary = Steam.get_steam_init_result() # Tjekker om der var fejl under steam hook.
	if init_response.is_empty():
		await get_tree().process_frame
		_on_tree_ready()
		return

	if init_response.status != Steam.STEAM_API_INIT_RESULT_OK:
		MenuHandler.change_menu("steam_error_popup")
	
	check_command_line()

func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()

	# There are arguments to process
	if these_arguments.size() > 0:

		# A Steam connection argument exists
		if these_arguments[0] == "+connect_lobby":

			# Lobby invite exists so try to connect to it
			if int(these_arguments[1]) > 0:

				Lobby.join_steam_lobby(these_arguments[1])
