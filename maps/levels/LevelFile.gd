@tool
extends Resource

class_name LevelFile 

@export var map_index :int
@export var gold_medal_seconds :int = 0
@export var silver_medal_seconds :int = 0
@export var bronze_medal_seconds :int = 0

@export_category("Map Files")
@export_tool_button("Verify Map Files", "ImportCheck")
var verify_action :Callable = _verify_map_files

## Insert transitions between non matching maps
@export var fill_missing_on_runtime :bool = false

@export var end_map_file :MapFile
@export var ordered_map_files :Array[MapFile] = []
@export var start_map_file :MapFile

func _verify_map_files() -> void:
	if not end_map_file:
		printerr("End map file missing!")
		return
	elif end_map_file.type != MapFile.MapType.END_MAP:
		printerr("End map type doesnt match")
		
	if not start_map_file:
		printerr("Start map file missing!")
		return
	elif start_map_file.type != MapFile.MapType.START_MAP:
		printerr("Start map type doesnt match")
		
	if ordered_map_files.is_empty():
		printerr("No map files are assinged!")
		return
	
	for i: int in ordered_map_files.size():
		var map :MapFile = ordered_map_files.get(i)
		if not map:
			printerr("Map at index %s is null" % i)
			continue
		
		if map.type != MapFile.MapType.REGULAR_MAP:
			printerr("Non regular map part at index %s in level body." % i)
			continue
		
		if i > 0:
			var prev_map :MapFile = ordered_map_files.get(i - 1)
			if not prev_map:
				continue
			
			if map.bottom_connection_type != prev_map.top_connection_type:
				printerr("Map connection at index %s doesnt match previous map. (%s != %s)" % [i, MapFile.MapType.keys()[map.bottom_connection_type], MapFile.MapType.keys()[prev_map.top_connection_type]])
			
	var first_map :MapFile = ordered_map_files.get(0)
	if first_map && first_map.bottom_connection_type != start_map_file.top_connection_type:
		printerr("First map doesnt match connection of start map (%s != %s)" % [MapFile.MapType.keys()[first_map.bottom_connection_type], MapFile.MapType.keys()[start_map_file.top_connection_type]])
	
	var last_map :MapFile = ordered_map_files.back()
	if last_map && last_map.top_connection_type != end_map_file.bottom_connection_type:
		printerr("Last map doesnt match connection of end map(%s != %s)" % [MapFile.MapType.keys()[last_map.top_connection_type], MapFile.MapType.keys()[end_map_file.bottom_connection_type]])
	

		
	
	return

func attempt_fill_missing() -> void:
	if fill_missing_on_runtime:
		fill_missing()

func fill_missing() -> void:
	print("LEVEL AUTO FILLING NOT IMPLEMENTED")
	
	return
