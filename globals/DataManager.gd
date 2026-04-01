extends Node

const DEFAULT_DIR :String = "user://"
const SAVE_FILE_NAME :String = "savegame.save"
const SETTINSG_FILE_NAME :String = "settings.ini"
var GAME_FILE_DIRECTORY_PATH :String = ""
const PREFIX :String = "[DataManager] "

signal save_game_completed

var config :ConfigFile = ConfigFile.new()
var game_data :Dictionary
var default_game_data: Dictionary = {
	"save_version" : 0.3,
	"money" : 0,
	"changelog_seen" : false,
	"selected_skin" : "Osvald",
	"selected_outline_hex" : "#ffffff",
	"owned_skin": {
		"Osvald": true,
		"Castro": false,
		"Edward": false,
		"Tiki": false,
	},
	"selected_accent" : "Brown",
	"owned_accent" : {
		"Brown" : true,
		"Blue" : false,
		"Gray" : false,
		"Green" : false,
		"Pink" : false,
		"Red" : false,
		"Black" : false,
	},
	"selected_theme" : "Default",
	"owned_theme" : {
		"Default" : true,
		"Hell" : false,
		"Abyss" : false,
		"Candy" : false,
		"Castle" : false,
		"Icey" : false, 
	},
}

func _init() -> void:
	if Steam.isSteamRunning():
		var steam_dir :String = Steam.getAppInstallDir(ProjectSettings.get_setting("steam/initialization/app_id")).replace("\\", "/")
		GAME_FILE_DIRECTORY_PATH = steam_dir + '/Saves/' + str(Steam.getSteamID()) + "/" #C:\Program Files (x86)\Steam\steamapps\common\Upward
	else:
		GAME_FILE_DIRECTORY_PATH = DEFAULT_DIR + '/Saves/' + 'non_steam' + "/"
	if !DirAccess.dir_exists_absolute(GAME_FILE_DIRECTORY_PATH):
		var err :Error = DirAccess.make_dir_recursive_absolute(GAME_FILE_DIRECTORY_PATH)
		if err != OK:
			print(PREFIX, "Failed to create directory at: \"", GAME_FILE_DIRECTORY_PATH, "\" With error code: \"", err, "\"")
	
	game_data = default_game_data.duplicate()
	if OS.is_debug_build():
		debug_data()
	load_save_data()
	load_config()

func _process(delta: float) -> void:
	Stats.add_float_stat(Stats.StatType.TIME_PlAYED, delta, false)

func debug_data() -> void:
	_create_new_save_data()
	set_value("money", 12456124)
	save_game_data()
	return

func update_game_data() -> void:
	var v: float = float(game_data["save_version"])
	print(PREFIX, "Updating save data, from: ", v, " to: ", default_game_data["save_version"])
	game_data["changelog_seen"] = false
	
	if v < 0.2:
		game_data["selected_outline_hex"] = default_game_data["selected_outline_hex"]
	
	game_data["save_version"] = default_game_data["save_version"]
	save_game_data()
	
func clear_game_data() -> void:
	print(PREFIX, "Clearing game data: ", game_data)
	DirAccess.remove_absolute(GAME_FILE_DIRECTORY_PATH + SAVE_FILE_NAME)
	load_save_data()
	create_config()
	
func save_game_data() -> void:
	var save_file :FileAccess = FileAccess.open(GAME_FILE_DIRECTORY_PATH + SAVE_FILE_NAME, FileAccess.WRITE)
	
	if !save_file:
		print(PREFIX, "Failed to open file access for saves. Error code: " ,FileAccess.get_open_error())
		
	var json_string :String = JSON.stringify(game_data)
	save_file.store_line(json_string)
	save_game_completed.emit()

func load_save_data() -> void:
	if not FileAccess.file_exists(GAME_FILE_DIRECTORY_PATH + SAVE_FILE_NAME):
		_create_new_save_data()
	
	var save_file :FileAccess = FileAccess.open(GAME_FILE_DIRECTORY_PATH + SAVE_FILE_NAME, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string :String = save_file.get_line()
		
		var json :JSON = JSON.new()
		
		var parse_result :Error = json.parse(json_string)
		if not parse_result == OK:
			print(PREFIX, "Json parsing error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		game_data = json.data
		if float(game_data["save_version"]) < float(default_game_data["save_version"]):
			update_game_data()
		
		print(PREFIX, "Succesfully loaded save data: ", json.data)
		
	return

func _create_new_save_data() -> void:
	print(PREFIX + "No save data found. Creating default save data, using default values.")
	game_data = default_game_data
	create_config()
	save_game_data()
	return

func set_value(key: String, value: Variant) -> void:
	game_data[key] = value

func get_value(key: String) -> Variant:
	var val :Variant = game_data[key]
	if val == null:
		print(PREFIX, "Value missing for key: ", key)
		return null
			
	return val

#region Config stuff
func create_config() -> void:
	config.set_value("keybinding", "move_left", "A")
	config.set_value("keybinding", "move_right", "D")
	config.set_value("keybinding", "jump", "W")
	config.set_value("keybinding", "fullscreen_toggle", "F11")
	config.set_value("keybinding", "restart", "R")
	config.set_value("keybinding", "escape", "Escape")
	
	config.set_value("audio", "master_volume", 0)
	config.set_value("audio", "music_volume", -15)
	
	config.set_value("video", "max_fps", 600)
	config.set_value("video", "show_fps", false)
	config.set_value("video", "vsync", false)
	config.set_value("video", "fullscreen", false)
	config.set_value("video", "color_theme", "Brown")
	config.set_value("video", "color_theme_id", 0)
	config.set_value("video", "particles_enabled", true)
	config.set_value("video", "skip_transitions", false)
	config.set_value("general", "default_controls", true)
	
	config.save(GAME_FILE_DIRECTORY_PATH + SETTINSG_FILE_NAME)

func load_config() -> void:
	if !FileAccess.file_exists(GAME_FILE_DIRECTORY_PATH + SETTINSG_FILE_NAME):
		create_config()
	else:
		var err :Error = config.load(GAME_FILE_DIRECTORY_PATH + SETTINSG_FILE_NAME)
	
		if err != OK:
			create_config()

func get_general_settings() -> Dictionary:
	var general_settings :Dictionary = {}
	for key in config.get_section_keys("general"):
		general_settings[key] = config.get_value("general", key)
	return general_settings

func save_general_setting(key: String, value: Variant) -> void:
	config.set_vale("general", key, value)
	config.save(GAME_FILE_DIRECTORY_PATH + SETTINSG_FILE_NAME)

func save_video_setting(key: String, value: Variant) -> void:
	config.set_value("video", key, value)
	config.save(GAME_FILE_DIRECTORY_PATH + SETTINSG_FILE_NAME)

func get_video_settings() -> Dictionary:
	var video_settings :Dictionary = {}	
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func save_audio_setting(key: String, value: Variant) -> void:
	config.set_value("audio", key, value)
	config.save(GAME_FILE_DIRECTORY_PATH + SETTINSG_FILE_NAME)

func get_audio_settings() -> Dictionary:
	var audio_settings :Dictionary = {}	
	for key: String in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

func save_keybinding(key: String, event: InputEvent) -> void:
	var event_str: String
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", key, event_str)
	config.save(GAME_FILE_DIRECTORY_PATH + SETTINSG_FILE_NAME)

func get_keybindings() -> Dictionary:
	var keybindings :Dictionary = {}
	for key: String in config.get_section_keys("keybinding"):
		var input_event: InputEvent
		var event_str :Variant = config.get_value("keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybindings[key] = input_event
		
	return keybindings
	
#endregion
