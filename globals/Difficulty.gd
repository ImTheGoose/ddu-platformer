extends Node

var selected_diffculty :Type = Type.VERY_EASY:
	set(value):
		selected_diffculty = value
		difficulty_changed.emit()

signal difficulty_changed

const DIFFICULTY_SETTINGS :Dictionary[Type, Dictionary] = {
	Type.VERY_EASY : {
		Settings.CAMERA_SPEED_SCALE : 0.4,
		Settings.ENEMY_SPAWN_RATE : 0.15,
		Settings.COLLECTABLE_SPAWN_RATE : 0.15,
		Settings.SPIKE_SPAWN_RATE : 0.2,
		Settings.PROJECTILE_SPEED_SCALE : 0.4,
		Settings.TRAP_TIMER_SPEED_SCALE : 1.4,
	},
	Type.EASY : {
		Settings.CAMERA_SPEED_SCALE : 0.8,
		Settings.ENEMY_SPAWN_RATE : 0.7,
		Settings.COLLECTABLE_SPAWN_RATE : 0.7,
	},
	Type.NORMAL : {
		Settings.CAMERA_SPEED_SCALE : 1.0,
		Settings.ENEMY_SPAWN_RATE : 0.85,
		Settings.COLLECTABLE_SPAWN_RATE : 0.85,
	},
	Type.HARD : {
		Settings.CAMERA_SPEED_SCALE : 1.1,
		Settings.ENEMY_SPAWN_RATE : 1.0,
		Settings.COLLECTABLE_SPAWN_RATE : 1.0,
	},
	Type.IMPOSSIBLE : {
		Settings.CAMERA_SPEED_SCALE : 1.3,
		Settings.ENEMY_SPAWN_RATE : 1.0,
		Settings.COLLECTABLE_SPAWN_RATE : 1.0,
		Settings.TRAP_TIMER_SPEED_SCALE : 0.65,
		Settings.PROJECTILE_SPEED_SCALE : 1.25,
	},
}

enum Type {
	VERY_EASY,
	EASY,
	NORMAL,
	HARD,
	IMPOSSIBLE,
}

enum Settings {
	CAMERA_SPEED_SCALE, #Required
	ENEMY_SPAWN_RATE, #Required
	COLLECTABLE_SPAWN_RATE, #Required
	SPIKE_SPAWN_RATE,
	TRAP_TIMER_SPEED_SCALE,
	PROJECTILE_SPEED_SCALE,
}

@rpc("authority", "call_local","reliable")
func set_difficulty(new_dif: Type) -> void:
	selected_diffculty = new_dif

func get_difficulty() -> Type:
	return selected_diffculty

func get_difficulty_settings() -> Dictionary:
	return DIFFICULTY_SETTINGS.get(selected_diffculty, {})

func get_setting(setting: Settings, default: Variant = null) -> Variant:
	return get_difficulty_settings().get(setting, default)

func has_setting(setting: Settings) -> bool:
	return get_difficulty_settings().has(setting)
	
