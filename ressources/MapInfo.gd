extends Resource

class_name  MapInfo

@export var prefab :PackedScene
@export var start_connection :connection_type
@export var end_connection :connection_type

enum connection_type {
	typeA,
	typeB,
	typeC,
	typeD,
	typeE
}
