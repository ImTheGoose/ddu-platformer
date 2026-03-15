extends Node

const MAP_FOLDER_PATHS :Dictionary[String, String] = {
	"default" : "res://maps/map_files/"
}

# A directory of every map that is loaded into memory. Not intended to be manipulated.
var loaded_map_files :Array[MapFile] = []

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_all_maps_on_initialise()
	print(loaded_map_files)

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

func get_transitions() -> void:
	pass

func get_maps_of_type(type: MapFile.MapType) -> void:
		
	pass


# Checks if the map can be played under current cirumstances. (eg difficulty, collection, etc)
func is_map_valid() -> bool:
	return true
