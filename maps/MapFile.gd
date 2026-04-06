extends Resource

class_name MapFile

# Custom map id which is used to reference a map, with a readable name.
@export var map_id :String = "_map_"

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

enum CollectionType {
	DEFAULT,
	LEGACY,
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
