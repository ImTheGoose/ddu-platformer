extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if !body.is_multiplayer_authority():
			return
			
		if !MenuHandler.is_game_visible():
			return
			
		if GameManager.get_state() != GameManager.STATE.PREGAME:
			return
			
		if body.dead:
			return
			
		if !body.reset_ready:
			return
			
		print("Starting Game from: %s "% multiplayer.get_unique_id())
		GameManager.rpc_id(1, "start_game")
