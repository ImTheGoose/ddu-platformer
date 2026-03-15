extends Node

const MAP_FOLDER_PATHS :Dictionary[String, String] = {
	"default" : "res://maps/map_files/"
}

# A directory of every map that is loaded into memory. Not intended to be manipulated.
var loaded_map_files :Array[MapFile] = []

var current_map_pool :Array[MapFile] = []:
	set(value):
		print("set map pool")
		if value.is_empty():
			current_map_pool = get_valid_regular_maps()
			current_map_pool.shuffle()
		else:
			current_map_pool = value
			current_map_pool.shuffle()
var current_transition_pool :Array[MapFile] = []
var current_start_pool :Array[MapFile] = []:
	set(value):
		print("set start pool")
		if value.is_empty():
			current_start_pool = get_valid_start_maps()
			current_start_pool.shuffle()
		else:
			current_start_pool = value
			current_start_pool.shuffle()

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	seed(int(Time.get_unix_time_from_system()))
	_load_all_maps_on_initialise()
	refresh_map_pools()

#region Map File Loading
# Every path in folder paths gets loaded.
func _load_all_maps_on_initialise() -> void:
	for path in MAP_FOLDER_PATHS.values():
		load_maps_from_folder(path)

func load_maps_from_folder(path: String) -> void:
	loaded_map_files.append_array(get_maps_from_folder(path))

func get_maps_from_folder(path: String) -> Array[MapFile]:
	var folder_map_files :Array[MapFile]
	
	for file_name in DirAccess.get_files_at(path):
		if file_name.get_extension() == "import": # On export files are moved, and need to be checked for file extensions.
			file_name.replace(".import", "")
		elif file_name.get_extension() == ".remap":
			file_name.replace(".remap", "")
		
		var loaded_file :Resource = load(path + file_name)
		if loaded_file is MapFile:
			folder_map_files.append(loaded_file)
		else:
			printerr("Loaded unknown ressource from mapfile folder. Filename is: ", file_name, " And ressource is: ", loaded_file)
		
	return folder_map_files
#endregion

#region Map Getting
func get_loaded_transitions() -> Array[MapFile]:
	return get_maps_matching_type(MapFile.MapType.TRANSITION_MAP)

func get_loaded_regular_maps() -> Array[MapFile]:
	return get_maps_matching_type(MapFile.MapType.REGULAR_MAP)

func get_valid_transitions() -> Array[MapFile]:
	return get_maps_matching_type(MapFile.MapType.TRANSITION_MAP, true)

func get_valid_regular_maps() -> Array[MapFile]:
	return get_maps_matching_type(MapFile.MapType.REGULAR_MAP, true)

func get_valid_start_maps() -> Array[MapFile]:
	return get_maps_matching_type(MapFile.MapType.START_MAP, true)

func get_maps_matching_type(type: MapFile.MapType, check_valid: bool = false) -> Array[MapFile]:
	var matching_map_files :Array[MapFile]
	for map_file in loaded_map_files:
		if map_file.type == type:
			if !check_valid or is_map_valid(map_file):
				matching_map_files.append(map_file)
	return matching_map_files
#endregion

func refresh_map_pools() -> void:
	current_map_pool = get_valid_regular_maps()
	current_transition_pool = get_valid_transitions()
	current_start_pool = get_valid_start_maps()

func get_start_map() -> MapFile:
	if current_start_pool.is_empty():
		current_start_pool = get_valid_start_maps()
		current_start_pool.shuffle()
	return current_start_pool.pop_back()

# Gets the next map, with nescessary transitions earlier in the array.
func get_next_map_section(current_connection: MapFile.ConnectionType) -> Array[MapFile]:
	var section :Array[MapFile] = []

	if current_map_pool.is_empty():
		current_map_pool = get_valid_regular_maps()
		current_map_pool.shuffle()

	var next_map :MapFile = current_map_pool.pop_back()
	if next_map.bottom_connection_type == current_connection:
		return [next_map]
	
	section = get_transition_section(current_connection, next_map.bottom_connection_type)
	section.append(next_map)
	
	return section

# Gets an ordered list of transitions from start to finish
func get_transition_section(from: MapFile.ConnectionType, to: MapFile.ConnectionType) -> Array[MapFile]:
	var first_transition :MapFile = get_transition(from, to)
	if first_transition != null:
		return [first_transition]
	
	first_transition = get_transition(from, MapFile.ConnectionType.TYPE_C)
	var second_transition = get_transition(MapFile.ConnectionType.TYPE_C, to)
	
	return [first_transition, second_transition]

# Gets a random transition that matches the types
func get_transition(from: MapFile.ConnectionType, to: MapFile.ConnectionType) -> MapFile:
	var transitions :Array[MapFile] = get_matching_transitions(from, to)
	if transitions.is_empty():
		return null
	else:
		return transitions.pick_random()

# Returns all matching transitions
func get_matching_transitions(from: MapFile.ConnectionType, to: MapFile.ConnectionType) -> Array[MapFile]:
	var matches :Array[MapFile] = []
	for trans in current_transition_pool:
		if trans.bottom_connection_type == from && trans.top_connection_type == to:
			matches.append(trans)
	return matches


# Checks if the map can be played under current cirumstances. (eg difficulty, collection, etc)
func is_map_valid(map_file: MapFile) -> bool:
	if !map_file.prefab:
		printerr("Map with id '%s' is missing prefab" % map_file.map_id)
		return false
	return true
