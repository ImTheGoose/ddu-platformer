extends Node

const MAP_FOLDER_PATHS :Dictionary[String, String] = {
	"default" : "res://maps/map_files/"
}

var loaded_mapfiles

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_all_maps_on_initialise()

func _load_all_maps_on_initialise() -> void:
	
	pass

func load_maps_from_folder(path: String) -> void:
	pass
