extends Node

const PATH :String = "user://savegame.save"
const SETTINGS_FILE_PATH :String = "user://settings.ini"
const PREFIX :String = "[DataManager] "

signal save_game_completed

var config = ConfigFile.new()
var game_data :Dictionary
var default_game_data: Dictionary = {
	"version" : float(ProjectSettings.get_setting("application/config/version")),
	"money" : 100000,
	"selected_skin" : "Osvald",
	"owned_skins": {
		"Osvald": true,
		"Castro": false,
		"Edward": false,
		"Tiki": false
	}
}

func _init() -> void:
	create_config()
	game_data = default_game_data.duplicate()
	load_save_data()
	load_config()

func update_game_data():
	var v: float = float(game_data["version"])
	print(PREFIX, "Updating save data, from: ", v, " to: ", ProjectSettings.get_setting("application/config/version"))
	
	#Example of how version specifik handling could look like.
	#if v < 0.7:
	#	print("Updating to 0.7")
		
	game_data["version"] = ProjectSettings.get_setting("application/config/version")
	save_game_data()
	
func clear_game_data():
	print(PREFIX, "Clearing game data: ", game_data)
	DirAccess.remove_absolute(PATH)
	game_data = default_game_data
	load_save_data()
	
func save_game_data():
	var save_file = FileAccess.open(PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(game_data)
	save_file.store_line(json_string)
	save_game_completed.emit()

func load_save_data():
	if not FileAccess.file_exists(PATH):
		_create_new_save_data()
	
	var save_file = FileAccess.open(PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print(PREFIX, "Json parsing error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		game_data = json.data
		if float(json.data["version"]) < float(ProjectSettings.get_setting("application/config/version")):
			update_game_data()
		
		print(PREFIX, "Succesfully loaded save data: ", json.data)
		
	return

func _create_new_save_data():
	print(PREFIX + "No save data found. Creating default save data, using default values.")
	save_game_data()
	return

func set_value(key: String, value) -> void:
	game_data[key] = value

func get_value(key: String):
	var val = game_data[key]
	if val == null:
		print(PREFIX, "Value missing for key: ", key)
		return null
			
	return val

#region Config stuff
func create_config():
	config.set_value("keybinding", "move_left", "A")
	config.set_value("keybinding", "move_right", "D")
	config.set_value("keybinding", "jump", "W")
	config.set_value("keybinding", "fullscreen_toggle", "F11")
	config.set_value("keybinding", "restart", "R")
	config.set_value("keybinding", "escape", "Escape")
	
	config.set_value("audio", "master_volume", 1.0)
	config.set_value("audio", "music_volume", 1.0)
	
	config.set_value("video", "resolution", 0)
	config.set_value("video", "fullscreen", false)
	config.set_value("video", "color_theme", "Brown")
	config.set_value("video", "color_theme_id", 0)
	config.set_value("video", "particles_enabled", true)
	
	config.save(SETTINGS_FILE_PATH)
	

func load_config():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		create_config()
	else:
		var err = config.load(SETTINGS_FILE_PATH)
	
		if err != OK:
			create_config()

func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func get_video_settings():
	var video_settings = {}	
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func get_audio_settings():
	var audio_settings = {}	
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

func save_keybinding(key: String, event: InputEvent):
	var event_str: String
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", key, event_str)
	config.save(SETTINGS_FILE_PATH)

func get_keybindings():
	var keybindings = {}
	for key in config.get_section_keys("keybinding"):
		var input_event: InputEvent
		var event_str = config.get_value("keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybindings[key] = input_event
		
	return keybindings
	
#endregion
