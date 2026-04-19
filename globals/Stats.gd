extends Node

#region Steam Handling
const STAT_API_NAMES :Dictionary[StatType, String] = {
	StatType.TIME_PlAYED : "TIME_PlAYED",
	StatType.TIME_ALIVE : "TIME_ALIVE",
	StatType.TOTAL_APPLES_COLLECTED : "TOTAL_APPLES_COLLECTED",
	StatType.JUMPS_GROUND : "JUMPS_GROUND",
	StatType.JUMPS_WALL : "JUMPS_WALL",
	StatType.JUMPS_DOUBLE : "JUMPS_DOUBLE",
	StatType.JUMPS_TRAMPOLINE : "JUMPS_TRAMPOLINE",
	StatType.JUMPS_KILL : "JUMPS_KILL",
	StatType.GROUP_TOTAL_DEATHS : "GROUP_TOTAL_DEATHS",
	StatType.GROUP_TOTAL_KILLS : "GROUP_TOTAL_KILLS",
	StatType.GROUP_TOTAL_JUMPS : "GROUP_TOTAL_JUMPS",
	StatType.HIGHSCORE_TIME_VERY_EASY : "HIGHSCORE_TIME_VERY_EASY",
	StatType.HIGHSCORE_TIME_EASY : "HIGHSCORE_TIME_EASY",
	StatType.HIGHSCORE_TIME_NORMAL : "HIGHSCORE_TIME_NORMAL",
	StatType.HIGHSCORE_TIME_HARD : "HIGHSCORE_TIME_HARD",
	StatType.HIGHSCORE_TIME_IMPOSSIBLE : "HIGHSCORE_TIME_IMPOSSIBLE",
	StatType.DEATH_MUSHROOM : "DEATH_MUSHROOM",
	StatType.DEATH_TRUNK : "DEATH_TRUNK",
	StatType.DEATH_PLANT : "DEATH_PLANT",
	StatType.DEATH_BIRD : "DEATH_BIRD",
	StatType.DEATH_FAT_BIRD : "DEATH_FAT_BIRD",
	StatType.DEATH_GHOST : "DEATH_GHOST",
	StatType.DEATH_ROCKS : "DEATH_ROCKS",
	StatType.DEATH_MOVING_HEAD : "DEATH_MOVING_HEAD",
	StatType.DEATH_SPIKED_HEAD : "DEATH_SPIKED_HEAD",
	StatType.DEATH_SPIKE : "DEATH_SPIKE",
	StatType.DEATH_FIRE : "DEATH_FIRE",
	StatType.DEATH_CLOUD : "DEATH_CLOUD",
	StatType.KILLS_MUSHROOM : "KILLS_MUSHROOM",
	StatType.KILLS_TRUNK : "KILLS_TRUNK",
	StatType.KILLS_PLANT : "KILLS_PLANT",
	StatType.KILLS_BIRD : "KILLS_BIRD",
	StatType.KILLS_FAT_BIRD : "KILLS_FAT_BIRD",
	StatType.KILLS_GHOST : "KILLS_GHOST",
	StatType.KILLS_ROCKS : "KILLS_ROCKS",
	StatType.MULTIPLAYER_MATCHES_WON : "MULTIPLAYER_MATCHES_WON",
	StatType.MULTIPLAYER_MATCHES_LOST : "MULTIPLAYER_MATCHES_LOST",
	StatType.MULTIPLAYER_ROUNDS_WON : "MULTIPLAYER_ROUNDS_WON",
	StatType.MULTIPLAYER_ROUNDS_LOST : "MULTIPLAYER_ROUNDS_LOST",
	StatType.HEIGHT_REACHED : "HEIGHT_REACHED",
	StatType.HIGHSCORE_HEIGHT_IMPOSSIBLE : "HIGHSCORE_HEIGHT_IMPOSSIBLE",
	StatType.HIGHSCORE_HEIGHT_HARD : "HIGHSCORE_HEIGHT_HARD",
	StatType.HIGHSCORE_HEIGHT_NORMAL : "HIGHSCORE_HEIGHT_NORMAL",
	StatType.HIGHSCORE_HEIGHT_EASY : "HIGHSCORE_HEIGHT_EASY",
	StatType.HIGHSCORE_HEIGHT_VERY_EASY : "HIGHSCORE_HEIGHT_VERY_EASY",
}

enum StatType {
	TIME_PlAYED,
	TIME_ALIVE,
	TOTAL_APPLES_COLLECTED,
	HIGHSCORE_TIME_VERY_EASY,
	HIGHSCORE_TIME_EASY,
	HIGHSCORE_TIME_NORMAL,
	HIGHSCORE_TIME_HARD,
	HIGHSCORE_TIME_IMPOSSIBLE,
	HIGHSCORE_HEIGHT_VERY_EASY,
	HIGHSCORE_HEIGHT_EASY,
	HIGHSCORE_HEIGHT_NORMAL,
	HIGHSCORE_HEIGHT_HARD,
	HIGHSCORE_HEIGHT_IMPOSSIBLE,
	DEATH_MUSHROOM,
	DEATH_TRUNK,
	DEATH_PLANT,
	DEATH_BIRD,
	DEATH_FAT_BIRD,
	DEATH_GHOST,
	DEATH_ROCKS,
	DEATH_MOVING_HEAD,
	DEATH_SPIKED_HEAD,
	DEATH_SPIKE,
	DEATH_FIRE,
	DEATH_CLOUD,
	KILLS_MUSHROOM,
	KILLS_TRUNK,
	KILLS_PLANT,
	KILLS_BIRD,
	KILLS_FAT_BIRD,
	KILLS_GHOST,
	KILLS_ROCKS,
	JUMPS_GROUND,
	JUMPS_WALL,
	JUMPS_DOUBLE,
	JUMPS_TRAMPOLINE,
	JUMPS_KILL,
	MULTIPLAYER_MATCHES_WON,
	MULTIPLAYER_MATCHES_LOST,
	MULTIPLAYER_ROUNDS_WON,
	MULTIPLAYER_ROUNDS_LOST,
	RECORDING_DEATH_TYPE,
	GROUP_TOTAL_DEATHS,
	GROUP_TOTAL_JUMPS,
	GROUP_TOTAL_KILLS,
	HEIGHT_REACHED,

}

enum StatGroup {
	GROUP_DEATHS,
	GROUP_JUMPS,
	GROUP_KILLS,
	GRPUP_TIME_HIGHSCORE,
	GROUP_APPLE_HIGHSCORE,
	GROUP_MULTIPLAYER_MATCHES,
	GROUP_MULTIPLAYER_ROUNDS,
	GROUP_HEIGHT_HIGHSCORE,
}

enum EnemyType {
	MUSHROOM,
	TRUNK,
	PLANT,
	BIRD,
	FAT_BIRD,
	GHOST,
	ROCKS,
	MOVING_HEAD,
	SPIKED_HEAD,
}

enum KillType {
	MUSHROOM,
	TRUNK,
	PLANT,
	BIRD,
	FAT_BIRD,
	GHOST,
	MOVING_HEAD,
	SPIKED_HEAD,
	ROCKS,
	SPIKE,
	FIRE,
	CLOUD,
}

func get_float_stat(stat: StatType) -> float:
	var stat_id: String = STAT_API_NAMES.get(stat, "")
	if stat_id == "":
		return -1.0
	return Steam.getStatFloat(stat_id)

func get_int_stat(stat: StatType) -> int:
	var stat_id: String = STAT_API_NAMES.get(stat, "")
	if stat_id == "":
		return -1
	return Steam.getStatInt(stat_id)

func set_float_stat(stat: StatType, new_value: float, snapped: bool = true) -> void:
	if !Steam.isSteamRunning():
		return
	
	var stat_id: String = STAT_API_NAMES.get(stat, "")
	if stat_id == "":
		return
		
	if snapped:
		snapped(new_value, 0.01)
	if not Steam.setStatFloat(stat_id, new_value):
		print("Error while setting stat %s to value %s" % [StatType.keys()[stat], new_value])

func set_int_stat(stat: StatType, new_value: int) -> void:
	if !Steam.isSteamRunning():
		return
	
	var stat_id: String = STAT_API_NAMES.get(stat, "")
	if stat_id == "":
		return
		
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

func get_group_max(group: StatGroup) -> float:
	var group_values :Array[float] = [0.0]
	match group:
		StatGroup.GRPUP_TIME_HIGHSCORE:
			group_values.append(get_float_stat(StatType.HIGHSCORE_TIME_VERY_EASY))
			group_values.append(get_float_stat(StatType.HIGHSCORE_TIME_EASY))
			group_values.append(get_float_stat(StatType.HIGHSCORE_TIME_NORMAL))
			group_values.append(get_float_stat(StatType.HIGHSCORE_TIME_HARD))
			group_values.append(get_float_stat(StatType.HIGHSCORE_TIME_IMPOSSIBLE))
		StatGroup.GROUP_HEIGHT_HIGHSCORE:
			group_values.append(get_float_stat(StatType.HIGHSCORE_HEIGHT_VERY_EASY))
			group_values.append(get_float_stat(StatType.HIGHSCORE_HEIGHT_EASY))
			group_values.append(get_float_stat(StatType.HIGHSCORE_HEIGHT_NORMAL))
			group_values.append(get_float_stat(StatType.HIGHSCORE_HEIGHT_HARD))
			group_values.append(get_float_stat(StatType.HIGHSCORE_HEIGHT_IMPOSSIBLE))

	return group_values.max()

func get_group_total(group: StatGroup) -> int:
	var total_value :int = 0
	match group:
		StatGroup.GROUP_DEATHS:
			total_value += get_int_stat(StatType.DEATH_MUSHROOM)
			total_value += get_int_stat(StatType.DEATH_TRUNK)
			total_value += get_int_stat(StatType.DEATH_PLANT)
			total_value += get_int_stat(StatType.DEATH_BIRD)
			total_value += get_int_stat(StatType.DEATH_FAT_BIRD)
			total_value += get_int_stat(StatType.DEATH_GHOST)
			total_value += get_int_stat(StatType.DEATH_ROCKS)
			total_value += get_int_stat(StatType.DEATH_MOVING_HEAD)
			total_value += get_int_stat(StatType.DEATH_SPIKED_HEAD)
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
			total_value += get_int_stat(StatType.KILLS_PLANT)
			total_value += get_int_stat(StatType.KILLS_BIRD)
			total_value += get_int_stat(StatType.KILLS_FAT_BIRD)
			total_value += get_int_stat(StatType.KILLS_GHOST)
			total_value += get_int_stat(StatType.KILLS_ROCKS)
		
		StatGroup.GROUP_MULTIPLAYER_MATCHES:
			total_value += get_int_stat(StatType.MULTIPLAYER_MATCHES_WON)
			total_value += get_int_stat(StatType.MULTIPLAYER_MATCHES_LOST)
		
		StatGroup.GROUP_MULTIPLAYER_ROUNDS:
			total_value += get_int_stat(StatType.MULTIPLAYER_ROUNDS_WON)
			total_value += get_int_stat(StatType.MULTIPLAYER_ROUNDS_LOST)
			
	return total_value

#endregion

const PREFIX := "[Statistics] "
var saved_recording :bool = true
var stat_recording :Dictionary = stat_template.duplicate()
const stat_template :Dictionary[StatType, Variant] = {
	StatType.TIME_ALIVE : 0.0,
	StatType.TOTAL_APPLES_COLLECTED : 0,
	StatType.HEIGHT_REACHED : 0.0,
	StatType.RECORDING_DEATH_TYPE : StatType.DEATH_MUSHROOM,
	StatType.KILLS_MUSHROOM : 0,
	StatType.KILLS_TRUNK : 0,
	StatType.KILLS_PLANT : 0,
	StatType.KILLS_BIRD : 0,
	StatType.KILLS_FAT_BIRD : 0,
	StatType.KILLS_GHOST : 0,
	StatType.KILLS_ROCKS : 0,
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
	if Lobby.is_lobby_local():
		return
	
	if GameManager.is_game_running() && !GameManager.is_game_paused() && GameManager.is_alive():
		add_recording_value(StatType.TIME_ALIVE, delta)

func _save_recording() -> void:
	if Lobby.is_lobby_local():
		print(PREFIX, "Stats doesnt apply to local games")
		return
	
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
					KillType.PLANT:
						add_int_stat(StatType.DEATH_PLANT)
					KillType.BIRD:
						add_int_stat(StatType.DEATH_BIRD)
					KillType.FAT_BIRD:
						add_int_stat(StatType.DEATH_FAT_BIRD)
					KillType.GHOST:
						add_int_stat(StatType.DEATH_GHOST)
					KillType.ROCKS:
						add_int_stat(StatType.DEATH_ROCKS)
					KillType.MOVING_HEAD:
						add_int_stat(StatType.DEATH_MOVING_HEAD)
					KillType.SPIKED_HEAD:
						add_int_stat(StatType.DEATH_SPIKED_HEAD)
					KillType.SPIKE:
						add_int_stat(StatType.DEATH_SPIKE)
					KillType.FIRE:
						add_int_stat(StatType.DEATH_FIRE)
					KillType.CLOUD:
						add_int_stat(StatType.DEATH_CLOUD)
						
				continue
			StatType.TIME_ALIVE:
				if not GameManager.is_playing_level():
					var dif_stat_type :StatType = get_time_highscore_type()
							
					if get_float_stat(dif_stat_type) < stat_value:
						set_float_stat(dif_stat_type, stat_value)
			StatType.HEIGHT_REACHED:
				if not GameManager.is_playing_level():
					var dif_stat_type :StatType = get_height_highscore_type()
					
					if get_float_stat(dif_stat_type) < stat_value:
						set_float_stat(dif_stat_type, stat_value)
		
		if typeof(stat_value) == TYPE_INT:
			add_int_stat(stat, stat_value)
		if typeof(stat_value) == TYPE_FLOAT:
			add_float_stat(stat, stat_value)
	
	Achivements.check_achivements()
	saved_recording = true
	Steamworks.store_steam_data()

#region Helper Function

func get_time_highscore_type(difficulty: int = -1) -> StatType:
	if difficulty == -1:
		difficulty = Difficulty.get_difficulty()
	match difficulty:
		Difficulty.Type.IMPOSSIBLE:
			return StatType.HIGHSCORE_TIME_IMPOSSIBLE
		Difficulty.Type.HARD:
			return StatType.HIGHSCORE_TIME_HARD
		Difficulty.Type.NORMAL:
			return StatType.HIGHSCORE_TIME_NORMAL
		Difficulty.Type.EASY:
			return StatType.HIGHSCORE_TIME_EASY
		_:
			return StatType.HIGHSCORE_TIME_VERY_EASY

func get_height_highscore_type(difficulty: int = -1) -> StatType:
	if difficulty == -1:
		difficulty = Difficulty.get_difficulty()
	match difficulty as Difficulty.Type:
		Difficulty.Type.IMPOSSIBLE:
			return StatType.HIGHSCORE_HEIGHT_IMPOSSIBLE
		Difficulty.Type.HARD:
			return StatType.HIGHSCORE_HEIGHT_HARD
		Difficulty.Type.NORMAL:
			return StatType.HIGHSCORE_HEIGHT_NORMAL
		Difficulty.Type.EASY:
			return StatType.HIGHSCORE_HEIGHT_EASY
		_:
			return StatType.HIGHSCORE_HEIGHT_VERY_EASY

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

func get_enemy_from_entity(entity_type: EntitySpawner.SpawnType) -> EnemyType:
	match entity_type:
		EntitySpawner.SpawnType.ENEMY_MUSHROOM:
			return EnemyType.MUSHROOM
		EntitySpawner.SpawnType.ENEMY_TRUNK:
			return EnemyType.TRUNK
		EntitySpawner.SpawnType.ENEMY_PLANT:
			return EnemyType.PLANT
		EntitySpawner.SpawnType.ENEMY_BIRD:
			return EnemyType.BIRD
		EntitySpawner.SpawnType.ENEMY_FAT_BIRD:
			return EnemyType.FAT_BIRD
		EntitySpawner.SpawnType.ENEMY_GHOST:
			return EnemyType.GHOST
		EntitySpawner.SpawnType.ENEMY_ROCKS_BIG, EntitySpawner.SpawnType.ENEMY_ROCKS_MEDIUM, EntitySpawner.SpawnType.ENEMY_ROCKS_SMALL:
			return EnemyType.ROCKS
		_:
			return EnemyType.MOVING_HEAD

func add_kill_to_recording(enemy_type: EnemyType) -> void:
	match enemy_type:
		EnemyType.MUSHROOM:
			add_recording_value(StatType.KILLS_MUSHROOM, 1)
		EnemyType.TRUNK:
			add_recording_value(StatType.KILLS_TRUNK, 1)
		EnemyType.PLANT:
			add_recording_value(StatType.KILLS_PLANT, 1)
		EnemyType.BIRD:
			add_recording_value(StatType.KILLS_BIRD, 1)
		EnemyType.FAT_BIRD:
			add_recording_value(StatType.KILLS_FAT_BIRD, 1)
		EnemyType.GHOST:
			add_recording_value(StatType.KILLS_GHOST, 1)
		EnemyType.ROCKS:
			add_recording_value(StatType.KILLS_ROCKS, 1)
	return


@rpc("authority","call_local","reliable")
func save_and_clear_match_scores() -> void:
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		return
	
	if GameManager.played_rounds == 0:
		return
	
	var rounds_won :int = GameManager.get_match_score(multiplayer.get_unique_id())
	var rounds_lost :int = GameManager.get_total_rounds() - rounds_won
	
	add_int_stat(Stats.StatType.MULTIPLAYER_ROUNDS_WON, rounds_won)
	add_int_stat(Stats.StatType.MULTIPLAYER_ROUNDS_LOST, rounds_lost)
	
	if GameManager.get_match_placement(multiplayer.get_unique_id()) == 1:
		add_int_stat(Stats.StatType.MULTIPLAYER_MATCHES_WON)
	else:
		add_int_stat(Stats.StatType.MULTIPLAYER_MATCHES_LOST)
	
	GameManager.match_scores.clear()
	GameManager.played_rounds = 0


#endregion
