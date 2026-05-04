extends Node

var data_upload_queued :bool = false

var ACHIVEMENT_STATES :Dictionary[Type, bool] = {}
const ACHIVEMENT_IDS :Dictionary[Type, String] = {
	Type.HUNTER_1: "HUNTER_1",
	Type.ALL_DEATHS_1: "ALL_DEATHS_1",
	Type.SHOP_1: "SHOP_1",
	Type.SHOP_2: "SHOP_2",
	Type.ANY_HIGHSCORE_60: "ANY_HIGHSCORE_60",
	Type.ANY_HIGHSCORE_120: "ANY_HIGHSCORE_120",
	Type.IMP_HIGHSCORE_180: "IMP_HIGHSCORE_180",
	Type.ANY_HIGHSCORE_EXACT_69: "ANY_HIGHSCORE_69",
	Type.KILL_MUSHROOM_2: "KILL_MUSHROOM_2",
	Type.GOLD_MEDALS_1: "GOLD_MEDALS_1",
	Type.ANY_HEIGHT_500: "ANY_HEIGHT_500",
	Type.ANY_HEIGHT_1000: "ANY_HEIGHT_1000",
	Type.MULTIPLAYER_1: "MULTIPLAYER_1",
}

enum Type {
	HUNTER_1,
	ALL_DEATHS_1,
	SHOP_1,
	SHOP_2,
	ANY_HIGHSCORE_60,
	ANY_HIGHSCORE_120,
	IMP_HIGHSCORE_180, #Changed to 120
	ANY_HIGHSCORE_EXACT_69,
	KILL_MUSHROOM_2,
	GOLD_MEDALS_1,
	ANY_HEIGHT_500, #Changed to 250
	ANY_HEIGHT_1000, #Changed to 500
	MULTIPLAYER_1,
}

func load_achivement(type: Type) -> void:
	var ach = Steam.getAchievement(ACHIVEMENT_IDS[type])
	if not ach:
		ACHIVEMENT_STATES.set(type, false)
		return
	
	if not ach["ret"]:
		print("Achivement doesnt exist in steamworks dashboard: %s" % Type.keys()[type])
		return
	
	ACHIVEMENT_STATES.set(type, ach["achieved"])
	
func is_achived(type: Type) -> bool:
	if !ACHIVEMENT_STATES.has(type):
		load_achivement(type)
		return is_achived(type)
		
	return ACHIVEMENT_STATES.get(type)

func set_achievement(achivement_type: Type) -> void:
	if not ACHIVEMENT_IDS.has(achivement_type):
		print("This achievement does not have a linked id: %s" % achivement_type)
		return

	if not Steam.setAchievement(ACHIVEMENT_IDS[achivement_type]):
		print("Failed to set achievement: %s with string id: %s" % [achivement_type, ACHIVEMENT_IDS[achivement_type]])
		return

	print("Set acheivement: %s" % achivement_type)
	ACHIVEMENT_STATES.set(achivement_type, true)
	data_upload_queued = true

func _init() -> void:
	set_process(PROCESS_MODE_ALWAYS)

func _ready() -> void:
	GameManager.client_reset.connect(func(): ACHIVEMENT_STATES.clear())

func _process(delta: float) -> void:
	if data_upload_queued:
		Steamworks.store_steam_data(true)
		data_upload_queued = false

	check_process_achivements()

func check_process_achivements() -> void:
	_check_any_highscore_60()
	_check_any_highscore_120()
	_check_imp_highscore_180()
	_check_any_height_500()
	_check_any_height_1000()
	return

#region Process Achivements

func _check_any_highscore_60() -> void:
	if not is_achived(Type.ANY_HIGHSCORE_60):
		if Stats.get_recording_value(Stats.StatType.TIME_ALIVE) >= 60:
			set_achievement(Type.ANY_HIGHSCORE_60)

func _check_any_highscore_120() -> void:
	if not is_achived(Type.ANY_HIGHSCORE_120):
		if Stats.get_recording_value(Stats.StatType.TIME_ALIVE) >= 120:
			set_achievement(Type.ANY_HIGHSCORE_120)

func _check_imp_highscore_180() -> void:
	if not is_achived(Type.IMP_HIGHSCORE_180):
		if Difficulty.get_difficulty() == Difficulty.Type.IMPOSSIBLE:
			if Stats.get_recording_value(Stats.StatType.TIME_ALIVE) >= 120: #Changed to 120
				set_achievement(Type.IMP_HIGHSCORE_180)

func _check_any_height_500() -> void:
	if not is_achived(Type.ANY_HEIGHT_500):
		if Stats.get_recording_value(Stats.StatType.HEIGHT_REACHED) >= 250: #Changed to 250
			set_achievement(Type.ANY_HEIGHT_500)

func _check_any_height_1000() -> void:
	if not is_achived(Type.ANY_HEIGHT_1000):
		if Stats.get_recording_value(Stats.StatType.HEIGHT_REACHED) >= 500: #Changed to 500
			set_achievement(Type.ANY_HEIGHT_1000)
#endregion

func check_recording_achivements() -> void:
	_check_hunter_achivement()
	_check_kill_mushroom_2()
	return

#region Recording Achivements

func _check_hunter_achivement() -> void:
	if not is_achived(Type.HUNTER_1):
		if Stats.get_recording_value(Stats.StatType.KILLS_MUSHROOM) <= 0:
			return
		if Stats.get_recording_value(Stats.StatType.KILLS_TRUNK) <= 0:
			return
		if Stats.get_recording_value(Stats.StatType.KILLS_PLANT) <= 0:
			return
		if Stats.get_recording_value(Stats.StatType.KILLS_BIRD) <= 0:
			return
		if Stats.get_recording_value(Stats.StatType.KILLS_FAT_BIRD) <= 0:
			return
		if Stats.get_recording_value(Stats.StatType.KILLS_GHOST) <= 0:
			return
		if Stats.get_recording_value(Stats.StatType.KILLS_ROCKS) <= 0:
			return
			
		set_achievement(Type.HUNTER_1)

func _check_kill_mushroom_2() -> void:
	if not is_achived(Type.KILL_MUSHROOM_2):
		if Stats.get_recording_value(Stats.StatType.KILLS_MUSHROOM) >= 20:
			set_achievement(Type.KILL_MUSHROOM_2)

#endregion


func check_achivements() -> void:
	_check_all_deaths_1()
	_check_shop_1()
	_check_shop_2()
	_check_gold_medals_1()
	return

#region Regular Acgivements

func _check_all_deaths_1() -> void:
	if not is_achived(Type.ALL_DEATHS_1):
		if Stats.get_int_stat(Stats.StatType.DEATH_MUSHROOM) < 10:
			return
			
		if Stats.get_int_stat(Stats.StatType.DEATH_TRUNK) < 10:
			return

		if Stats.get_int_stat(Stats.StatType.DEATH_PLANT) < 10:
			return
			
		if Stats.get_int_stat(Stats.StatType.DEATH_BIRD) < 10:
			return

		if Stats.get_int_stat(Stats.StatType.DEATH_FAT_BIRD) < 10:
			return
			
		if Stats.get_int_stat(Stats.StatType.DEATH_GHOST) < 10:
			return

		if Stats.get_int_stat(Stats.StatType.DEATH_ROCKS) < 10:
			return
			
		if Stats.get_int_stat(Stats.StatType.DEATH_MOVING_HEAD) < 10:
			return

		if Stats.get_int_stat(Stats.StatType.DEATH_SPIKED_HEAD) < 10:
			return

		if Stats.get_int_stat(Stats.StatType.DEATH_SPIKE) < 10:
			return
			
		if Stats.get_int_stat(Stats.StatType.DEATH_FIRE) < 10:
			return
			
		if Stats.get_int_stat(Stats.StatType.DEATH_CLOUD) < 10:
			return
		
		set_achievement(Type.ALL_DEATHS_1)

func _check_shop_1() -> void:
	if not is_achived(Type.SHOP_1):
		var owned_skins :Dictionary = DataManager.get_value("owned_skin")
		if owned_skins.values().has(false):
			return
		
		var owned_accents :Dictionary = DataManager.get_value("owned_accent")
		if owned_accents.values().has(false):
			return
			
		var owned_themes :Dictionary = DataManager.get_value("owned_theme")
		if owned_themes.values().has(false):
			return
	
		set_achievement(Type.SHOP_1)

func _check_shop_2() -> void:
	if not is_achived(Type.SHOP_2):
		var owned_skins :Dictionary = DataManager.get_value("owned_skin")
		owned_skins.erase("Osvald")
		if not owned_skins.values().has(true):
			return
		
		var owned_accents :Dictionary = DataManager.get_value("owned_accent")
		owned_accents.erase("Brown")
		if not owned_accents.values().has(true):
			return
			
		var owned_themes :Dictionary = DataManager.get_value("owned_theme")
		owned_themes.erase("Default")
		if not owned_themes.values().has(true):
			return
	
		set_achievement(Type.SHOP_2)

func _check_any_highscore_69() -> void:
	if not is_achived(Type.ANY_HIGHSCORE_EXACT_69):
		var time: float = Stats.get_recording_value(Stats.StatType.TIME_ALIVE)
		if time >= 69.0 && time < 70.0:
			set_achievement(Type.ANY_HIGHSCORE_EXACT_69)

func _check_gold_medals_1() -> void:
	if not is_achived(Type.GOLD_MEDALS_1):
		var medal_times :Dictionary = DataManager.get_value("level_times")
		var gold_medals: int = 0
		for lvl_idx: String in medal_times.keys():
			var idx: int = int(lvl_idx)
			if not Levels.is_level_playable(idx):
				continue
			
			var time: float = medal_times.get(lvl_idx)
			var lvl_file :LevelFile = Levels.get_level(idx)
			if time > lvl_file.gold_medal_seconds:
				gold_medals += 1
		
		if gold_medals >= 10:
			set_achievement(Type.GOLD_MEDALS_1)


#endregion
