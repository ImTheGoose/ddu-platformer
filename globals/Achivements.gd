extends Node

const ACHIVEMENT_IDS :Dictionary[Type, String] = {
	Type.TEST: "ach_test",
}

enum Type {
	TEST,
}

func set_achievement(achivement_type: Type) -> void:
	if not ACHIVEMENT_IDS.has(achivement_type):
		print("This achievement does not have a linked id: %s" % achivement_type)
		return

	if not Steam.setAchievement(ACHIVEMENT_IDS[achivement_type]):
		print("Failed to set achievement: %s with string id: %s" % [achivement_type, ACHIVEMENT_IDS[achivement_type]])
		return

	print("Set acheivement: %s" % achivement_type)
	store_steam_data()
