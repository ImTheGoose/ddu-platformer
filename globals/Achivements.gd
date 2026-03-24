extends Node

var data_upload_queued :bool = false

const ACHIVEMENT_IDS :Dictionary[Type, String] = {
	Type.DEATHS_50 : "DEATHS_1", #AUTO
	Type.DEATHS_150 : "DEATHS_2", #AUTO
	Type.HIGHSCORE_60 : "HIGHSCORE_1", 
	Type.HIGHSCORE_IMP_120 : "HIGHSCORE_2",
	Type.JUMP_TRAMP_100 : "JUMPS_1", #AUTO
	Type.HIGHSCORE_APL_100 : "HIGHSCORE_APPLE_1",
	Type.APPLE_TOTAL_5k : "APPLE_1",
}

enum Type {
	DEATHS_50,
	DEATHS_150,
	HIGHSCORE_60,
	HIGHSCORE_IMP_120,
	JUMP_TRAMP_100,
	HIGHSCORE_APL_100,
	APPLE_TOTAL_5k,
}

func is_achived(type: Type) -> bool:
	var ach = Steam.getAchievement(ACHIVEMENT_IDS[type])
	if not ach["ret"]:
		return false
	
	return ach["achieved"]

func set_achievement(achivement_type: Type) -> void:
	if not ACHIVEMENT_IDS.has(achivement_type):
		print("This achievement does not have a linked id: %s" % achivement_type)
		return

	if not Steam.setAchievement(ACHIVEMENT_IDS[achivement_type]):
		print("Failed to set achievement: %s with string id: %s" % [achivement_type, ACHIVEMENT_IDS[achivement_type]])
		return

	print("Set acheivement: %s" % achivement_type)
	data_upload_queued = true

func _init() -> void:
	set_process(PROCESS_MODE_ALWAYS)

func _process(delta: float) -> void:
	if data_upload_queued:
		Steamworks.store_steam_data(true)
		data_upload_queued = false

	check_process_achivements()

func check_process_achivements() -> void:
	_check_highscore_achivements()
	return

#region Process Achivements

func _check_highscore_achivements() -> void:
	if not is_achived(Type.HIGHSCORE_60):
		if Stats.get_recording_value(Stats.StatType.TIME_ALIVE) > 60:
			set_achievement(Type.HIGHSCORE_60)
	
	if not is_achived(Type.HIGHSCORE_IMP_120):
		if Stats.get_recording_value(Stats.StatType.TIME_ALIVE) > 120 && GameManager.get_difficulty() == GameManager.difficulty.IMPOSSIBLE:
			set_achievement(Type.HIGHSCORE_IMP_120)
	
	if not is_achived(Type.HIGHSCORE_APL_100):
		if Stats.get_recording_value(Stats.StatType.TOTAL_APPLES_COLLECTED) > 100:
			set_achievement(Type.HIGHSCORE_APL_100)

#endregion

func check_achivements() -> void:
	_check_apple_achivements()
	return

#region Regular Acgivements

func _check_apple_achivements() -> void:
	if not is_achived(Type.APPLE_TOTAL_5k):
		if DataManager.get_value("money") > 5000:
			set_achievement(Type.APPLE_TOTAL_5k)

#endregion
