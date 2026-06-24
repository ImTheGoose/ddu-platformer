extends Node

const LEVEL_FOLDER_PATHS :Dictionary[String, String] = {
	"default" : "res://maps/levels/test_level_files/",
}

# A directory of every map that is loaded into memory. Not intended to be manipulated.
var loaded_level_files :Dictionary[int, LevelFile] = {}
var highest_level :int = -1
var selected_level :int = 0

signal selected_level_changed(level_index: int)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_all_levels_on_ready()
	Maps.refresh_map_pools()
	print("Loaded files: ", loaded_level_files)
	

func get_highest_level_index() -> int:
	if highest_level != -1:
		return highest_level
	
	for key:int in loaded_level_files.keys():
		if key > highest_level:
			highest_level = key
	
	return highest_level
	
#func _ready() -> void:
	#refresh_map_pools()

#region Map File Loading
# Every path in folder paths gets loaded.
func _load_all_levels_on_ready() -> void:
	for path: String in LEVEL_FOLDER_PATHS.values():
		load_levels_from_folder(path)

func load_levels_from_folder(path: String) -> void:
	for sub_path: String in DirAccess.get_directories_at(path):
		load_levels_from_folder(path + sub_path + "/")
	
	loaded_level_files.assign(get_levels_from_folder(path))

func get_levels_from_folder(path: String) -> Dictionary[int, LevelFile]:
	var folder_level_files :Dictionary[int, LevelFile] = {}
	
	for file_name in DirAccess.get_files_at(path):
		var full_file_name :String = file_name
		if file_name.get_extension() == "import": # On export files are moved, and need to be checked for file extensions.
			file_name = file_name.replace(".import", "")
		if file_name.get_extension() == "remap":
			file_name = file_name.replace(".remap", "")
		
		var loaded_file :Resource = load(path + file_name)
		if loaded_file is LevelFile:
			if not folder_level_files.has(loaded_file.map_index) && not loaded_level_files.has(loaded_file.map_index):
				if loaded_file.fill_missing_on_runtime:
					print("Filling missing on map index: %s. Filename is: %s" % [loaded_file.map_index, file_name])
					fill_missing_on_level(loaded_file)
				
				if loaded_file.is_valid():
					folder_level_files.set(loaded_file.map_index, loaded_file)
				else:
					print("level with name: %s not valid" % file_name)
				
			else:
				printerr("Level with duplicate index. Filename is: ", file_name)
		else:
			printerr("Loaded unknown ressource from levelfile folder. Filename is: ", file_name, " File script is: ", loaded_file.get_script(), " Full filename is: ", full_file_name, " And ressource is: ", loaded_file)
		
	return folder_level_files

func fill_missing_on_level(level_file: LevelFile) -> void:
	if not level_file.start_map_file:
		level_file.start_map_file = Maps.get_maps_matching_type(MapFile.MapType.START_MAP).pick_random()
	
	if not level_file.end_map_file:
		level_file.end_map_file = Maps.get_maps_matching_type(MapFile.MapType.END_MAP).pick_random()
	
	Maps.current_transition_pool = Maps.get_loaded_maps(MapFile.MapType.TRANSITION_MAP)
	var filled_ordered_list :Array[MapFile]
		
	for i:int in range(level_file.ordered_map_files.size()):
		var map: MapFile = level_file.ordered_map_files[i]
		if not map:
			continue
		
		if i > 0:
			var prev_map: MapFile = level_file.ordered_map_files[i - 1]
			if prev_map:
				if map.bottom_connection_type != prev_map.top_connection_type:
					filled_ordered_list.append_array(Maps.get_transition_section(prev_map.top_connection_type, map.bottom_connection_type))

		filled_ordered_list.append(map)
	if not filled_ordered_list.is_empty():
		var first_map :MapFile = filled_ordered_list.get(0)
		if level_file.start_map_file.top_connection_type != first_map.bottom_connection_type:
			var new_filled_list :Array[MapFile] = Maps.get_transition_section(level_file.start_map_file.top_connection_type, first_map.bottom_connection_type)
			new_filled_list.append_array(filled_ordered_list)
			filled_ordered_list = new_filled_list
		
		var last_map :MapFile = filled_ordered_list.back()
		if last_map.top_connection_type != level_file.end_map_file.bottom_connection_type:
			filled_ordered_list.append_array(Maps.get_transition_section(last_map.top_connection_type, level_file.end_map_file.bottom_connection_type))
	else:
		filled_ordered_list = Maps.get_transition_section(level_file.start_map_file.top_connection_type, level_file.end_map_file.bottom_connection_type)
	level_file.ordered_map_files = filled_ordered_list
	level_file.fill_missing_on_runtime = false
	var err :Error = ResourceSaver.save(level_file, level_file.resource_path)
	if err != OK:
		print("Failed to save ressource file: %s. Failed with error code: %s. Try manually saving ressource.")

#endregion

func update_level_time() -> void:
	var level_index :int = Levels.get_level_index()
	var level_times :Dictionary = DataManager.get_value("level_times")
	var time :float = level_times.get(str(level_index), 0.0)
	var new_time :float = Stats.get_recording_value(Stats.StatType.TIME_ALIVE)
	
	if new_time < time or time <= 0.0:
		level_times.set(str(level_index), new_time)
		DataManager.set_value("level_times", level_times)
		print("Updated level times")
	
	return

func get_level_time(index: int) -> float:
	var level_times :Dictionary = DataManager.get_value("level_times")
	return level_times.get(str(index), 0.0)

func select_level(index: int) -> void:
	selected_level = index
	selected_level_changed.emit(index)

func get_level_index() -> int:
	return selected_level

func get_level(index: int) -> LevelFile:
	return loaded_level_files.get(index, loaded_level_files.values()[0])

func is_level_playable(index: int) -> bool:
	if not loaded_level_files.has(index):
		return false
	
	if DataManager.get_value("unlocked_level") < index:
		return false
	
	return true
