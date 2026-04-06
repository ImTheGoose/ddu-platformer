extends Node

const STEAM_DATA_COOLDOWN :float = 15.0
var steam_data_cooldown_progress :float = 0.0

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	get_tree().root.ready.connect(_on_tree_ready)
	Steam.initRelayNetworkAccess()
	set_rich_presense("#InMenu")
	DiscordRPC.register_steam(Steam.getSteamID())
	DiscordRPC.app_id = 1490022810473730333
	# this is boolean if everything worked
	print("Discord working: " + str(DiscordRPC.get_is_discord_working()))
	# Set the first custom text row of the activity here
	DiscordRPC.details = "An infinite 2D platformer"
	# Set the second custom text row of the activity here
	DiscordRPC.state = "Singleplayer"
	# Image key for small image from "Art Assets" from the Discord Developer website
	DiscordRPC.large_image = "big_icon"
	# Tooltip text for the large image
	DiscordRPC.large_image_text = "Try it now!"
	
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())

	DiscordRPC.refresh() 

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

func update_discord_presense() -> void:
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		DiscordRPC.state = "Playing Solo"
	elif MenuHandler.is_game_visible():
		DiscordRPC.state = "Playing Online (%s / 4)" % (multiplayer.get_peers().size() + 1)
	else:
		DiscordRPC.state = "In Lobby (%s / 4)" % (multiplayer.get_peers().size() + 1)
	
	DiscordRPC.refresh()
	return

func set_rich_presense(token:String, value: String = "") -> void:
	var setting_presence: bool = false
	if value == "":
		setting_presence = Steam.setRichPresence("steam_display", token)
	else:
		setting_presence= Steam.setRichPresence(token, value)
	
	update_discord_presense()

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
