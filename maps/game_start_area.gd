extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if !body.is_multiplayer_authority():
			return
			
		if !MenuHandler.is_game_visible():
			return
			
		if body.dead:
			return
			
		if !body.reset_ready:
			return
			
		body.spawn_position.y = get_child(0).global_position.y
		
		if GameManager.get_state() != GameManager.STATE.PREGAME:
			return
			
		print("Starting Game from: %s "% multiplayer.get_unique_id())
		GameManager.rpc_id(1, "start_game")
