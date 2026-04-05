extends GameMenu

const statistics_entries = [
	# --- TIME STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/time (16x16).png[/img] Time played",
		"stat_type": Stats.StatType.TIME_PlAYED,
		"stat_group" : -1,
		"value_type": ValueType.TYPE_FORMATTED_TIME
	},
	{
		"bbcode": "[img]res://assets/icons/heart_red (16x16).png[/img] Time alive",
		"stat_type": Stats.StatType.TIME_ALIVE,
		"stat_group" : -1,
		"value_type": ValueType.TYPE_FORMATTED_TIME
	},
	{
		"bbcode": "[img]res://assets/icons/star (16x16).png[/img] Highscore",
		"stat_type": Stats.StatType.HIGHSCORE_TIME_VERY_EASY,
		"stat_group" : -1,
		"value_type": ValueType.TYPE_FORMATTED_TIME
	},

	# --- APPLE STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/star_red (16x16).png[/img] Most apples in a round",
		"stat_type": Stats.StatType.HIGHSCORE_TIME_VERY_EASY,
		"stat_group" : -1,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img] Apples collected",
		"stat_type": Stats.StatType.TOTAL_APPLES_COLLECTED,
		"stat_group" : -1,
		"value_type": ValueType.TYPE_INT
	},

	# --- JUMP STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/lightning (16x16).png[/img] Total Jumps",
		"stat_type": -1,
		"stat_group" : Stats.StatGroup.GROUP_JUMPS,
		"value_type": ValueType.TYPE_ID_TOTAL
	},
	{
		"bbcode": "[img]res://assets/icons/ground (16x16).png[/img] Ground jumps",
		"stat_type": Stats.StatType.JUMPS_GROUND,
		"stat_group" : Stats.StatGroup.GROUP_JUMPS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/wall (16x16).png[/img] Wall jumps",
		"stat_type": Stats.StatType.JUMPS_WALL,
		"stat_group" : Stats.StatGroup.GROUP_JUMPS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/double_jump (16x16).png[/img] Double jumps",
		"stat_type": Stats.StatType.JUMPS_DOUBLE,
		"stat_group" : Stats.StatGroup.GROUP_JUMPS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/trampoline (16x16).png[/img] Trampoline jumps",
		"stat_type": Stats.StatType.JUMPS_TRAMPOLINE,
		"stat_group" : Stats.StatGroup.GROUP_JUMPS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/dual_enemy (16x16).png[/img] Enemy jumps",
		"stat_type": Stats.StatType.JUMPS_KILL,
		"stat_group" : Stats.StatGroup.GROUP_JUMPS,
		"value_type": ValueType.TYPE_INT
	},

	# --- DEATH STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/bone_skull (16x16).png[/img] Total Deaths",
		"stat_type": -1,
		"stat_group" : Stats.StatGroup.GROUP_DEATHS,
		"value_type": ValueType.TYPE_ID_TOTAL
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Mushroom/Icon (16x16).png[/img] Mushrooms deaths",
		"stat_type": Stats.StatType.DEATH_MUSHROOM,
		"stat_group" : Stats.StatGroup.GROUP_DEATHS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Trunk/Trunk (16x16).png[/img] Trunks deaths",
		"stat_type": Stats.StatType.DEATH_TRUNK,
		"stat_group" : Stats.StatGroup.GROUP_DEATHS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Traps/Spikes/Icon (16x16).png[/img] Spike deaths",
		"stat_type": Stats.StatType.DEATH_SPIKE,
		"stat_group" : Stats.StatGroup.GROUP_DEATHS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Traps/Fire/Icon (16x16).png[/img] Fire deaths",
		"stat_type": Stats.StatType.DEATH_FIRE,
		"stat_group" : Stats.StatGroup.GROUP_DEATHS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Other/Dust Particle.png[/img] Cloud deaths",
		"stat_type": Stats.StatType.DEATH_CLOUD,
		"stat_group" : Stats.StatGroup.GROUP_DEATHS,
		"value_type": ValueType.TYPE_INT
	},

	# --- KILL STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/dual_enemy (16x16).png[/img] Total kills",
		"stat_type": -1,
		"stat_group" : Stats.StatGroup.GROUP_KILLS,
		"value_type": ValueType.TYPE_ID_TOTAL
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Mushroom/Icon (16x16).png[/img] Mushrooms killed",
		"stat_type": Stats.StatType.KILLS_MUSHROOM,
		"stat_group" : Stats.StatGroup.GROUP_KILLS,
		"value_type": ValueType.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Trunk/Trunk (16x16).png[/img] Trunks killed",
		"stat_type": Stats.StatType.KILLS_TRUNK,
		"stat_group" : Stats.StatGroup.GROUP_KILLS,
		"value_type": ValueType.TYPE_INT
	}
]

enum ValueType {
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_FORMATTED_TIME,
	TYPE_ID_TOTAL,
}

@onready var stat_list_container :VBoxContainer = %StatisticsList

func _on_show() -> void:
	_refresh_stat_list()

func _refresh_stat_list() -> void:
	return
	_clear_children()
	for entry: Dictionary in statistics_entries:
		_instantiate_entry(entry)

func _clear_children() -> void:
	for c in stat_list_container.get_children():
		c.queue_free()

func _instantiate_entry(entry: Dictionary) -> void:
	var string_value :String = _get_entry_string_value(entry)
	var bbcode :String = entry["bbcode"]
	
	var label :RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = bbcode + " - " + string_value
	label.fit_content = true
	label.focus_mode =Control.FOCUS_ALL 
	stat_list_container.add_child(label)		
	
func _get_entry_string_value(entry: Dictionary) -> String:
	var stat_type :Stats.StatType = entry["stat_type"]
	var stat_group :Stats.StatGroup = entry["stat_group"]
	var value_type :ValueType = entry["value_type"]
	
	
	if value_type == ValueType.TYPE_ID_TOTAL:
		return str( int( Stats.get_group_total(stat_group)))
	
	if value_type == ValueType.TYPE_FORMATTED_TIME:
		var value :float = Stats.get_float_stat(stat_type)
		return TimeFormat.get_time_string(value, 0.1)
	
	if value_type == ValueType.TYPE_FLOAT:
		return str( float( Stats.get_float_stat(stat_type)))
	
	return str( int( Stats.get_int_stat(stat_type)))

func _on_back_pressed() -> void:
	MenuHandler.change_menu("main_menu")
