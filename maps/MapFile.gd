@tool
extends Resource

class_name MapFile

# Custom map id which is used to reference a map, with a readable name.
@export var map_id :String = ""

@export_tool_button("Create or Select map prefab","CreateNewSceneFrom")
var button_action :Callable = editor_button_pressed

# The godot scene for the map itself
@export var prefab: PackedScene

# The bottom connection type, which has to match the last maps.
@export var bottom_connection_type: ConnectionType

# The upper connection type, which is used to find the next map parts
@export var top_connection_type: ConnectionType

@export var type :MapType = MapType.REGULAR_MAP

# Collections that the maps is a part of.
@export var related_collections :Array[CollectionType] = [CollectionType.UNDER_DEVELOPMENT]

@export var blacklisted_difficulties :Array[Difficulty.Type] = []

# If the map is useable in a multiplayer context
@export var is_multiplayer_compatible :bool = true

const VISIBLE_COLLECTIONS_IN_RELEASE :Array[CollectionType] = [
	CollectionType.DEFAULT,
	CollectionType.LEGACY,
	CollectionType.TEST_MAPS,
]

enum CollectionType {
	DEFAULT,
	LEGACY,
	NEW_MAPS,
	UNDER_DEVELOPMENT,
	IN_REVIEW,
	TEST_MAPS,
}

# Transition maps arent a part of the map pool, and can therefore be shown multiple times per map clean.
enum MapType {
	REGULAR_MAP,
	TRANSITION_MAP,
	START_MAP,
}

enum ConnectionType {
	TYPE_A,
	TYPE_B,
	TYPE_C,
	TYPE_D,
	TYPE_E,
}

#region Map Creation Tool
const SAMPLE_MAP_UID :String = "uid://ddwqswon7sfyp"
const DEFAULT_DIRECTORY :String = "res://maps/prefabs/"
var file_dialog :EditorFileDialog

func editor_button_pressed() -> void:
	if prefab:
		printerr("A map prefab is already assigned to this Mapfile.")
		return
		
	var uid :int = ResourceUID.text_to_id(SAMPLE_MAP_UID)
	if not ResourceUID.has_id(uid):
		printerr("Sample map UID doesn't exist in RessourceUID")
		return
	
	var sample_map_path :String = ResourceUID.get_id_path(ResourceUID.text_to_id(SAMPLE_MAP_UID))
	var dir :String = sample_map_path.get_base_dir()
	if DirAccess.dir_exists_absolute(DEFAULT_DIRECTORY) && DEFAULT_DIRECTORY != "":
		dir = DEFAULT_DIRECTORY
	
	var file_name :String = "%s.%s" % [map_id, sample_map_path.get_extension()]
	_show_save_dialog(dir, file_name)

func _show_save_dialog(dir: String, file_name: String) -> void:
	reference()
	file_dialog = EditorFileDialog.new()
	
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.add_filter("*.tscn", "Scene File")
	
	file_dialog.current_dir = dir
	file_dialog.current_file = file_name
	
	file_dialog.confirmed.connect(_on_confirmed)
	file_dialog.canceled.connect(_remove_ref)
	
	EditorInterface.get_base_control().add_child(file_dialog)
	file_dialog.popup_centered_ratio(0.4)

func _on_confirmed() -> void:
	var sample_map_path :String = ResourceUID.get_id_path(ResourceUID.text_to_id(SAMPLE_MAP_UID))
	var path :String = file_dialog.current_path
	if not FileAccess.file_exists(path):
		var err :Error = DirAccess.copy_absolute(sample_map_path, path)
		
		if err == OK:
			print("Map prefab successfully created at: ", path)
		else:
			push_error("Copy failed with error: ", err)
			_remove_ref()
			return
			
	print("Map prefab: %s, has been selected." % path.get_file())
	prefab = load(path) as PackedScene
	
	if map_id == "":
		map_id = path.get_file().get_basename()
	
	_remove_ref()
	
	var err :Error = ResourceSaver.save(self, resource_path)
	if err != OK:
		push_error("Something went wrong when saving ressource file to system. Error says %s with code: %s" % [error_string(err), err])
	
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.open_scene_from_path(path)
	var tree = EditorInterface.get_base_control().get_tree()
	await tree.process_frame
	await tree.process_frame
	await tree.process_frame
	EditorInterface.set_main_screen_editor("2D")
	notify_property_list_changed()

func _remove_ref() -> void:
	file_dialog.queue_free()
	unreference()

#endregion
