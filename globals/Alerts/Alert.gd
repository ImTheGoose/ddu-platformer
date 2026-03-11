extends Resource

class_name Alert

@export var title :String = "Title"
@export var description :String = "Description"
@export var seconds_active :float = 3.0
@export var type :Types = Types.default

enum Types {
	default,
	success,
	warning,
	error,
}

const COLORS :Dictionary[Types, Color] = {
	Types.default : Color.DIM_GRAY,
	Types.success : Color.WEB_GREEN,
	Types.warning : Color.ORANGE,
	Types.error : Color.RED
}
