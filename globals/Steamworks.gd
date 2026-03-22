extends Node

const STEAM_DATA_COOLDOWN :float = 15.0
var steam_data_cooldown_progress :float = 0.0

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	get_tree().root.ready.connect(_on_tree_ready)
	Steam.initRelayNetworkAccess()
	set_rich_presense("#InMenu")

func _process(delta: float) -> void:
	Steam.run_callbacks()
	steam_data_cooldown_progress += delta
	
func _on_tree_ready() -> void:
	var init_response :Dictionary = Steam.get_steam_init_result() # Tjekker om der var fejl under steam hook.
	if init_response.is_empty():
		await get_tree().process_frame
		_on_tree_ready()
		return

	if init_response.status != Steam.STEAM_API_INIT_RESULT_OK:
		MenuHandler.change_menu("steam_error_popup")
	
	check_command_line()

func set_rich_presense(token:String, value: String = "") -> void:
	var setting_presence: bool = false
	if value == "":
		setting_presence = Steam.setRichPresence("steam_display", token)
	else:
		setting_presence= Steam.setRichPresence(token, value)

	# Debug it
	print("Setting rich presence to %s: %s" % [token, setting_presence])
	
	pass


func store_steam_data(forced:bool = false, attempt: int = 0) -> void:
	if attempt > 3:
		print("Failed to store data on Steam. Too many attempts.")
		return
	
	if !forced:
		if steam_data_cooldown_progress < STEAM_DATA_COOLDOWN:
			return
	
	Stats.sync_group_totals()
	
	if not Steam.storeStats():
		print("Failed to store data on Steam, trying again.")
		store_steam_data(true, attempt + 1)
		return

	steam_data_cooldown_progress = 0.0
	print("Data successfully sent to Steam")

func reset_steam_stats(attempt: int = 0) -> void:
	if attempt > 3:
		print("Failed to reset data on Steam. Too many attempts.")
		return
	
	if not Steam.resetAllStats(true):
		print("Failed to reset data on Steam, trying again.")
		reset_steam_stats(attempt + 1)
		return
	print("Data successfully reset on steam.")

func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()

	# There are arguments to process
	if these_arguments.size() > 0:

		# A Steam connection argument exists
		if these_arguments[0] == "+connect_lobby":

			# Lobby invite exists so try to connect to it
			if int(these_arguments[1]) > 0:

				Lobby.join_steam_lobby(these_arguments[1])
