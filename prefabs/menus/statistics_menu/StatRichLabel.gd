extends RichTextLabel

class_name StatRichLabel 

@export var stat_type :Stats.StatType = Stats.StatType.TIME_PlAYED
@export var stat_group :Stats.StatGroup = Stats.StatGroup.GROUP_DEATHS
@export var value_type :ValueType = ValueType.TYPE_INT

var menu_root_control :GameMenu

enum ValueType {
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_FORMATTED_TIME,
	TYPE_GROUP_TOTAL,
	TYPE_GROUP_MAX,
}

var bbcode_spacing :String = " "
var original_bbcode :String = ""
var original_text :String = ""

func _ready() -> void:
	menu_root_control = get_menu_root(self)
	if menu_root_control:
		menu_root_control.visibility_changed.connect(_on_root_visible_changed)
	
	var split_string :Array = split_bbcode_content(text)
	original_bbcode = split_string[0]
	original_text = split_string[1]
	bbcode_enabled = true
	fit_content = true
	focus_mode = Control.FOCUS_ALL
	_refresh_label()

func split_bbcode_content(full_text: String) -> Array:
	var regex = RegEx.new()
	# Pattern logic:
	# ^(\[img\].*?\[\/img\]) -> Capture the full img tag at the start
	# \s* -> Ignore any whitespace after the tag
	# (.*)$                 -> Capture everything else as the second group
	regex.compile("^(\\[img\\].*?\\[\\/img\\])\\s*(.*)$")
	
	var result = regex.search(full_text)
	
	if result:
		var bbcode_part = result.get_string(1)
		var rest_part = result.get_string(2)
		return [bbcode_part, rest_part]
		
	return ["", full_text] # Fallback if no tag found

func _on_root_visible_changed() -> void:
	_refresh_label()

func get_menu_root(child: Control) -> GameMenu:
	var parent :Control = child.get_parent_control()
	if not parent:
		return null
	
	if parent is GameMenu:
		return parent
	
	return get_menu_root(parent)

func _refresh_label() -> void:
	var new_text :String = original_bbcode + bbcode_spacing
	if original_text.contains("%"):
		new_text += original_text % _get_string_value()
	else:
		new_text += original_text
	text = new_text

func _get_string_value() -> String:
	match value_type:
		ValueType.TYPE_GROUP_MAX:
			var float_value :float = Stats.get_group_max(stat_group)
			if is_equal_approx(float_value, round(float_value)):
				return str( int( float_value))
			else:
				return TimeFormat.get_time_string(float_value, 0.1)
		
		ValueType.TYPE_GROUP_TOTAL:
			return str( int( Stats.get_group_total(stat_group)))
		ValueType.TYPE_FORMATTED_TIME:
			var value :float = Stats.get_float_stat(stat_type)
			return TimeFormat.get_time_string(value, 0.1)
		ValueType.TYPE_FLOAT:
			return str( float( Stats.get_float_stat(stat_type)))
	
	return str( int( Stats.get_int_stat(stat_type)))
	
