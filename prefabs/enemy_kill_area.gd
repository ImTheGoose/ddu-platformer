extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if GameManager.game_state == GameManager.state.dead:
		return
	
	if area.get_parent() is PathfindingEnemy:
		area.get_parent().die()
		get_parent().velocity.y = -1000
	pass # Replace with function body.
