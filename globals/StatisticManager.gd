extends Node

const prefix := "[Statistics] "
var stat_recording :Dictionary = stat_template.duplicate()
const stat_template :Dictionary = {
	"time_alive" : 0.0,
	"apples_collected" : 0,
	"death_type" : death_type.cloud,
	"mushroom_killed" : 0,
	"trunk_killed" : 0,
	"ground_jump" : 0,
	"wall_jump" : 0,
	"double_jump" : 0,
	"trampoline_jump" : 0,
	"kill_jump" : 0,
}

enum death_type {
	mushroom,
	trunk,
	spike,
	fire,
	cloud
}

func _ready() -> void:
	GameManager.on_player_death.connect(_save_recording)
	GameManager.on_reset_game.connect(_clear_recording)

func _save_recording():
	var glo_stats = DataManager.get_value("statistics")
	
	glo_stats["total_apples_collected"] += stat_recording["apples_collected"]
	glo_stats["time_alive"] += stat_recording["time_alive"]
	
	glo_stats["kills"]["mushroom"] += stat_recording["mushroom_killed"]
	glo_stats["kills"]["trunk"] += stat_recording["trunk_killed"]
	
	var jumps = glo_stats["jumps"]
	jumps["ground"] += stat_recording["ground_jump"]
	jumps["wall"] += stat_recording["wall_jump"]
	jumps["double"] += stat_recording["double_jump"]
	jumps["trampoline"] += stat_recording["trampoline_jump"]
	jumps["kill"] += stat_recording["kill_jump"]
	glo_stats["jumps"] = jumps
	
	match stat_recording["death_type"]:
		death_type.mushroom:
			glo_stats["deaths"]["mushroom"] += 1
			
		death_type.trunk:
			glo_stats["deaths"]["trunk"] += 1
			
		death_type.spike:
			glo_stats["deaths"]["spike"] += 1
			
		death_type.fire:
			glo_stats["deaths"]["fire"] += 1
			
		death_type.cloud:
			glo_stats["deaths"]["cloud"] += 1
			
	
	if glo_stats["time_highscore"] < stat_recording["time_alive"]:
		print(prefix, "player reached new time highscore. New time: ", stat_recording["time_alive"])
		glo_stats["time_highscore"] = stat_recording["time_alive"]
	
	if glo_stats["apple_highscore"] < stat_recording["apples_collected"]:
		print(prefix, "player reached new apple highscore. New apple score: ", stat_recording["apples_collected"])
		glo_stats["apple_highscore"] = stat_recording["apples_collected"]
	
	print(prefix, "updated player statistics from current run")
	DataManager.set_value("statistics", glo_stats)
	DataManager.save_game_data()

func set_value(key: String, value):
	stat_recording[key] = value

func add_value(key: String, value):
	stat_recording[key] += value

func get_value(key:String):
	return stat_recording[key]

func _process(delta: float) -> void:
	if GameManager.game_state == GameManager.state.running:
		stat_recording["time_alive"] += delta

func _clear_recording():
	stat_recording = stat_template.duplicate()
	return
