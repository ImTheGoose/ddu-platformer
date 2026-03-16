extends GameMenu

const statistics_entries = [
	# --- TIME STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/time (16x16).png[/img] Time played",
		"stat_id": "time_played",
		"stat_subid": "none",
		"stat_type": STAT_TYPE.TYPE_FORMATTED_TIME
	},
	{
		"bbcode": "[img]res://assets/icons/heart_red (16x16).png[/img] Time alive",
		"stat_id": "time_alive",
		"stat_subid": "none",
		"stat_type": STAT_TYPE.TYPE_FORMATTED_TIME
	},
	{
		"bbcode": "[img]res://assets/icons/star (16x16).png[/img] Highscore",
		"stat_id": "time_highscore",
		"stat_subid": "none",
		"stat_type": STAT_TYPE.TYPE_FORMATTED_TIME
	},

	# --- APPLE STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/star_red (16x16).png[/img] Most apples in a round",
		"stat_id": "apple_highscore",
		"stat_subid": "none",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img] Apples collected",
		"stat_id": "total_apples_collected",
		"stat_subid": "none",
		"stat_type": STAT_TYPE.TYPE_INT
	},

	# --- JUMP STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/lightning (16x16).png[/img] Total Jumps",
		"stat_id": "jumps",
		"stat_subid": "none", # Aggregated total
		"stat_type": STAT_TYPE.TYPE_ID_TOTAL
	},
	{
		"bbcode": "[img]res://assets/icons/ground (16x16).png[/img] Ground jumps",
		"stat_id": "jumps",
		"stat_subid": "ground",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/wall (16x16).png[/img] Wall jumps",
		"stat_id": "jumps",
		"stat_subid": "wall",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/double_jump (16x16).png[/img] Double jumps",
		"stat_id": "jumps",
		"stat_subid": "double",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/trampoline (16x16).png[/img] Trampoline jumps",
		"stat_id": "jumps",
		"stat_subid": "trampoline",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/icons/dual_enemy (16x16).png[/img] Enemy jumps",
		"stat_id": "jumps",
		"stat_subid": "kill",
		"stat_type": STAT_TYPE.TYPE_INT
	},

	# --- DEATH STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/bone_skull (16x16).png[/img] Total Deaths",
		"stat_id": "deaths",
		"stat_subid": "none", # Aggregated total
		"stat_type": STAT_TYPE.TYPE_ID_TOTAL
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Mushroom/Icon (16x16).png[/img] Mushrooms deaths",
		"stat_id": "deaths",
		"stat_subid": "mushroom",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Trunk/Trunk (16x16).png[/img] Trunks deaths",
		"stat_id": "deaths",
		"stat_subid": "trunk",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Traps/Spikes/Icon (16x16).png[/img] Spike deaths",
		"stat_id": "deaths",
		"stat_subid": "spike",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Traps/Fire/Icon (16x16).png[/img] Fire deaths",
		"stat_id": "deaths",
		"stat_subid": "fire",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Other/Dust Particle.png[/img] Cloud deaths",
		"stat_id": "deaths",
		"stat_subid": "cloud",
		"stat_type": STAT_TYPE.TYPE_INT
	},

	# --- KILL STATISTICS ---
	{
		"bbcode": "[img]res://assets/icons/dual_enemy (16x16).png[/img] Total kills",
		"stat_id": "kills",
		"stat_subid": "none", # Aggregated total
		"stat_type": STAT_TYPE.TYPE_ID_TOTAL
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Mushroom/Icon (16x16).png[/img] Mushrooms killed",
		"stat_id": "kills",
		"stat_subid": "mushroom",
		"stat_type": STAT_TYPE.TYPE_INT
	},
	{
		"bbcode": "[img]res://assets/pixel_adventure_assets/Enemies/Trunk/Trunk (16x16).png[/img] Trunks killed",
		"stat_id": "kills",
		"stat_subid": "trunk",
		"stat_type": STAT_TYPE.TYPE_INT
	}
]

enum STAT_TYPE {
	TYPE_INT,
	TYPE_FORMATTED_TIME,
	TYPE_ID_TOTAL,
}

@onready var stat_list_container :VBoxContainer = %StatisticsList

func _on_show() -> void:
	_refresh_stat_list()

func _refresh_stat_list() -> void:
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
	var stats :Dictionary = DataManager.get_value("statistics")

	var stat_id :String = entry["stat_id"]
	var stat_subid :String = entry["stat_subid"]
	var stat_type :STAT_TYPE = entry["stat_type"]
	
	var value :Variant = ""
	
	if stat_subid != "none":
		value = stats[stat_id][stat_subid]
	else:
		value = stats[stat_id]
		
	if stat_type == STAT_TYPE.TYPE_FORMATTED_TIME:
		return TimeFormat.get_time_string(value)
	if stat_type == STAT_TYPE.TYPE_INT:
		return str(int(value))
	if value is not Dictionary:
		return "ERROR NOT DICTIONARY"

	var value_dict :Dictionary = value
	var combined_value :float = 0.0
	
	for key: Variant in value_dict.keys():
		combined_value += value_dict[key]
	
	return str(int(combined_value))

func _on_back_pressed() -> void:
	MenuHandler.change_menu("main_menu")
