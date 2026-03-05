extends GameMenu

const bbcode_string = "[img]res://assets/icons/time (16x16).png[/img] Time played - {time_played}
[img]res://assets/icons/heart_red (16x16).png[/img] Time alive - {time_alive}
[img]res://assets/icons/star (16x16).png[/img] Highscore - {time_highscore}
[img]res://assets/icons/star_red (16x16).png[/img] Most apples in a round - {apple_highscore}
[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img] Apples collected - {total_apples_collected}

[img]res://assets/icons/lightning (16x16).png[/img] Total Jumps - {total_jumps}
[img]res://assets/icons/ground (16x16).png[/img] Ground jumps - {ground_jumps}
[img]res://assets/icons/wall (16x16).png[/img] Wall jumps - {wall_jumps}
[img]res://assets/icons/double_jump (16x16).png[/img] Double jumps - {double_jumps}
[img]res://assets/icons/trampoline (16x16).png[/img] Trampoline jumps - {trampoline_jumps}
[img]res://assets/icons/dual_enemy (16x16).png[/img] Enemy jumps - {enemy_jumps}

[img]res://assets/icons/bone_skull (16x16).png[/img] Total Deaths - {total_deaths}
[img]res://assets/pixel_adventure_assets/Enemies/Mushroom/Icon (16x16).png[/img] Mushrooms deaths - {mushroom_deaths}
[img]res://assets/pixel_adventure_assets/Enemies/Trunk/Trunk (16x16).png[/img] Trunks deaths - {trunk_deaths}
[img]res://assets/pixel_adventure_assets/Traps/Spikes/Icon (16x16).png[/img] Spike deaths - {spike_deaths}
[img]res://assets/pixel_adventure_assets/Traps/Fire/Icon (16x16).png[/img] Fire deaths - {fire_deaths}
[img]res://assets/pixel_adventure_assets/Other/Dust Particle.png[/img] Cloud deaths - {cloud_deaths}

[img]res://assets/icons/dual_enemy (16x16).png[/img] Total kills - {total_killed}
[img]res://assets/pixel_adventure_assets/Enemies/Mushroom/Icon (16x16).png[/img] Mushrooms killed - {mushroom_killed}
[img]res://assets/pixel_adventure_assets/Enemies/Trunk/Trunk (16x16).png[/img] Trunks killed - {trunk_killed}"

@onready var text_node :RichTextLabel = %stat_rich_label

func _on_show() -> void:
	_refresh_text()
		
func _refresh_text() -> void:
	var stats :Dictionary = DataManager.get_value("statistics")
	text_node.text = bbcode_string.format({
		"time_played" : TimeFormat.get_time_string(stats["time_played"]),
		"time_alive" : TimeFormat.get_time_string(stats["time_alive"]),
		"time_highscore" : TimeFormat.get_time_string(stats["time_highscore"]),
		"apple_highscore" : int(stats["apple_highscore"]),
		"total_apples_collected" : int(stats["total_apples_collected"]),
		"total_jumps" : int(stats["jumps"]["ground"] + stats["jumps"]["wall"] + stats["jumps"]["double"] + stats["jumps"]["trampoline"] + stats["jumps"]["kill"]),
		"ground_jumps" : int(stats["jumps"]["ground"]),
		"wall_jumps" : int(stats["jumps"]["wall"]),
		"double_jumps" : int(stats["jumps"]["double"]),
		"trampoline_jumps" : int(stats["jumps"]["trampoline"]),
		"enemy_jumps" : int(stats["jumps"]["kill"]),
		"total_deaths" : int(stats["deaths"]["mushroom"] + stats["deaths"]["trunk"] + stats["deaths"]["spike"] + stats["deaths"]["fire"] + stats["deaths"]["cloud"]),
		"mushroom_deaths" : int(stats["deaths"]["mushroom"]),
		"trunk_deaths" : int(stats["deaths"]["trunk"]),
		"spike_deaths" : int(stats["deaths"]["spike"]),
		"fire_deaths" : int(stats["deaths"]["fire"]),
		"cloud_deaths" : int(stats["deaths"]["cloud"]),
		"total_killed" : int(stats["kills"]["mushroom"] + stats["kills"]["trunk"]),
		"mushroom_killed" : int(stats["kills"]["mushroom"]),
		"trunk_killed" : int(stats["kills"]["trunk"]),
	})

func _on_back_pressed() -> void:
	MenuHandler.change_menu("main_menu")
