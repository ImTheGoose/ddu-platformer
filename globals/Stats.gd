extends Node

#region Steam Handling
const STAT_IDS :Dictionary[StatType, String] = {
	StatType.TIME_PlAYED : "time_played",
	StatType.TIME_ALIVE : "time_alive",
	StatType.TOTAL_APPLES_COLLECTED : "total_apples",
	StatType.HIGHSCORE_TIME : "highscore_time",
	StatType.HIGHSCORE_APPLE : "highscore_apple",
	StatType.DEATH_MUSHROOM : "death_mushroom",
	StatType.DEATH_TRUNK : "death_trunk",
	StatType.DEATH_SPIKE : "death_spike",
	StatType.DEATH_FIRE : "death_fire",
	StatType.DEATH_CLOUD : "death_cloud",
	StatType.KILLS_MUSHROOM : "kills_mushroom",
	StatType.KILLS_TRUNK : "kills_trunk",
	StatType.JUMPS_GROUND : "jumps_ground",
	StatType.JUMPS_WALL : "jumps_wall",
	StatType.JUMPS_DOUBLE : "jumps_double",
	StatType.JUMPS_TRAMPOLINE : "jumps_trampoline",
	StatType.JUMPS_KILL : "jumps_kill",
	StatType.GROUP_TOTAL_DEATHS : "group_total_deaths",
	StatType.GROUP_TOTAL_KILLS : "group_total_kills",
	StatType.GROUP_TOTAL_JUMPS : "group_total_jumps",
	
}

enum StatType {
	TIME_PlAYED,
	TIME_ALIVE,
	TOTAL_APPLES_COLLECTED,
	HIGHSCORE_TIME,
	HIGHSCORE_APPLE,
	DEATH_MUSHROOM,
	DEATH_TRUNK,
	DEATH_SPIKE,
	DEATH_FIRE,
	DEATH_CLOUD,
	KILLS_MUSHROOM,
	KILLS_TRUNK,
	JUMPS_GROUND,
	JUMPS_WALL,
	JUMPS_DOUBLE,
	JUMPS_TRAMPOLINE,
	JUMPS_KILL,
	RECORDING_DEATH_TYPE,
	GROUP_TOTAL_DEATHS,
	GROUP_TOTAL_JUMPS,
	GROUP_TOTAL_KILLS,
}

enum StatGroup {
	GROUP_DEATHS,
	GROUP_JUMPS,
	GROUP_KILLS,
}

enum EnemyType {
	MUSHROOM,
	TRUNK
}

enum KillType {
	MUSHROOM,
	TRUNK,
	SPIKE,
	FIRE,
	CLOUD,
}

func get_float_stat(stat: StatType) -> float:
	var stat_id: String = STAT_IDS[stat]
	return Steam.getStatFloat(stat_id)

func get_int_stat(stat: StatType) -> int:
	var stat_id: String = STAT_IDS[stat]
	return Steam.getStatInt(stat_id)

func set_float_stat(stat: StatType, new_value: float, snapped: bool = true) -> void:
	if !Steam.isSteamRunning():
		return
	
	var stat_id: String = STAT_IDS[stat]
	if snapped:
		snapped(new_value, 0.01)
	if not Steam.setStatFloat(stat_id, new_value):
		print("Error while setting stat %s to value %s" % [StatType.keys()[stat], new_value])

func set_int_stat(stat: StatType, new_value: int) -> void:
	if !Steam.isSteamRunning():
		return
	
	var stat_id: String = STAT_IDS[stat]
	if not Steam.setStatInt(stat_id, new_value):
		print("Error while setting stat %s to value %s" % [StatType.keys()[stat], new_value])

func add_float_stat(stat: StatType, added_value: float, snapped: bool = true) -> void:
	var old_value: float = get_float_stat(stat)
	if snapped:
		snappedf(added_value, 0.01)
	set_float_stat(stat, old_value + added_value)

func add_int_stat(stat: StatType, added_value: int = 1) -> void:
	var old_value: int = get_int_stat(stat)
	set_int_stat(stat, old_value + added_value)

func sync_group_totals() -> void:
	set_int_stat(StatType.GROUP_TOTAL_DEATHS, get_group_total(StatGroup.GROUP_DEATHS))
	set_int_stat(StatType.GROUP_TOTAL_JUMPS, get_group_total(StatGroup.GROUP_JUMPS))
	set_int_stat(StatType.GROUP_TOTAL_KILLS, get_group_total(StatGroup.GROUP_KILLS))

func get_group_total(group: StatGroup) -> int:
	var total_value :int = 0
	match group:
		StatGroup.GROUP_DEATHS:
			total_value += get_int_stat(StatType.DEATH_MUSHROOM)
			total_value += get_int_stat(StatType.DEATH_TRUNK)
			total_value += get_int_stat(StatType.DEATH_SPIKE)
			total_value += get_int_stat(StatType.DEATH_FIRE)
			total_value += get_int_stat(StatType.DEATH_CLOUD)
			
		StatGroup.GROUP_JUMPS:
			total_value += get_int_stat(StatType.JUMPS_GROUND)
			total_value += get_int_stat(StatType.JUMPS_WALL)
			total_value += get_int_stat(StatType.JUMPS_DOUBLE)
			total_value += get_int_stat(StatType.JUMPS_TRAMPOLINE)
			total_value += get_int_stat(StatType.JUMPS_KILL)
			
		StatGroup.GROUP_KILLS:
			total_value += get_int_stat(StatType.KILLS_MUSHROOM)
			total_value += get_int_stat(StatType.KILLS_TRUNK)
			
	return total_value

#endregion

const PREFIX := "[Statistics] "
var saved_recording :bool = true
var stat_recording :Dictionary = stat_template.duplicate()
const stat_template :Dictionary[StatType, Variant] = {
	StatType.TIME_ALIVE : 0.0,
	StatType.TOTAL_APPLES_COLLECTED : 0,
	StatType.RECORDING_DEATH_TYPE : StatType.DEATH_MUSHROOM,
	StatType.KILLS_MUSHROOM : 0,
	StatType.KILLS_TRUNK : 0,
	StatType.JUMPS_GROUND : 0,
	StatType.JUMPS_WALL : 0,
	StatType.JUMPS_DOUBLE : 0,
	StatType.JUMPS_TRAMPOLINE : 0,
	StatType.JUMPS_KILL : 0,
}


func _clear_recording() -> void:
	stat_recording = stat_template.duplicate()
	saved_recording = false

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	GameManager.player_death.connect(_on_player_death)
	GameManager.client_reset.connect(_clear_recording)

func _on_player_death(peer_id: int) -> void:
	if peer_id == multiplayer.get_unique_id():
		_save_recording()

func _process(delta: float) -> void:
	if GameManager.is_game_running() && !GameManager.is_game_paused() && GameManager.is_alive():
		add_recording_value(StatType.TIME_ALIVE, delta)

func _save_recording() -> void:
	if saved_recording:
		print(PREFIX, "Error attempted to save recording another time.")
		return

	for stat in stat_recording.keys():
		var stat_value = stat_recording[stat]
		
		match stat:
			StatType.RECORDING_DEATH_TYPE:
				match stat_value:
					KillType.MUSHROOM:
						add_int_stat(StatType.DEATH_MUSHROOM)
					KillType.TRUNK:
						add_int_stat(StatType.DEATH_TRUNK)
					KillType.SPIKE:
						add_int_stat(StatType.DEATH_SPIKE)
					KillType.FIRE:
						add_int_stat(StatType.DEATH_FIRE)
					KillType.CLOUD:
						add_int_stat(StatType.DEATH_CLOUD)
						
				continue
			StatType.TIME_ALIVE:
				if get_float_stat(StatType.HIGHSCORE_TIME) < stat_value:
					set_float_stat(StatType.HIGHSCORE_TIME, stat_value)
			StatType.TOTAL_APPLES_COLLECTED:
				if get_int_stat(StatType.HIGHSCORE_APPLE) < stat_value:
					set_int_stat(StatType.HIGHSCORE_APPLE, stat_value)
		
		if typeof(stat_value) == TYPE_INT:
			add_int_stat(stat, stat_value)
		if typeof(stat_value) == TYPE_FLOAT:
			add_float_stat(stat, stat_value)
	
	Achivements.check_achivements()
	saved_recording = true
	Steamworks.store_steam_data()

#region Helper Function

func set_recording_value(stat: StatType, new_value: Variant) -> void:
	if not stat_recording.has(stat):
		print(PREFIX, "Error when setting recording value %s to value %s" % [StatType.keys()[stat], new_value])
	
	stat_recording.set(stat, new_value)

func get_recording_value(stat: StatType) -> Variant:
	if not stat_recording.has(stat):
		print(PREFIX, "Error when getting recording value %s" % StatType.keys()[stat])
		return 0
	
	return stat_recording.get(stat)

func add_recording_value(stat: StatType, added_value: Variant) -> void:
	var old_value :Variant = get_recording_value(stat)
	set_recording_value(stat, old_value + added_value)

func get_recording_group_total(group: StatGroup) -> int:
	var total_value :int = 0
	match group:
		StatGroup.GROUP_DEATHS:
			total_value += get_recording_value(StatType.DEATH_MUSHROOM)
			total_value += get_recording_value(StatType.DEATH_TRUNK)
			total_value += get_recording_value(StatType.DEATH_SPIKE)
			total_value += get_recording_value(StatType.DEATH_FIRE)
			total_value += get_recording_value(StatType.DEATH_CLOUD)
			
		StatGroup.GROUP_JUMPS:
			total_value += get_recording_value(StatType.JUMPS_GROUND)
			total_value += get_recording_value(StatType.JUMPS_WALL)
			total_value += get_recording_value(StatType.JUMPS_DOUBLE)
			total_value += get_recording_value(StatType.JUMPS_TRAMPOLINE)
			total_value += get_recording_value(StatType.JUMPS_KILL)
			
		StatGroup.GROUP_KILLS:
			total_value += get_recording_value(StatType.KILLS_MUSHROOM)
			total_value += get_recording_value(StatType.KILLS_TRUNK)
			
	return total_value

func add_kill_to_recording(enemy_type: EnemyType) -> void:
	match enemy_type:
		EnemyType.MUSHROOM:
			add_recording_value(StatType.KILLS_MUSHROOM, 1)
		EnemyType.TRUNK:
			add_recording_value(StatType.KILLS_TRUNK, 1)
	return

#endregion
