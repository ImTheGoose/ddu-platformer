extends Area2D


func _init() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if is_multiplayer_authority():
		return
		#if area.get_parent() is PathfindingEnemy:
			#if get_parent().is_on_floor():
				#return
			#area.get_parent().rpc("die")
			#Stats.add_kill_to_recording(area.get_parent().enemy_type)
			#
			#get_parent().velocity.y = -1000
			#get_parent().double_jumped = false
			#Stats.add_recording_value(Stats.StatType.JUMPS_KILL, 1)
