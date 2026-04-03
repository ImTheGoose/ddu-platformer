extends Node2D

class_name ProjectileSpawnerComponent 

@export var projectile :PackedScene
signal projectile_spawned

func spawn_projectile(direction: Vector2) -> Node2D:
	var p: Projectile = projectile.instantiate()
	add_sibling(p)
	p.global_rotation = direction.rotated(global_rotation).angle()
	
	# Changes offset based on direction
	var pos :Vector2 = Vector2(-position.x, 0)
	pos.x -= position.x * direction.x
	print(pos)
	
	p.global_position = to_global(pos)
	projectile_spawned.emit()
	return p
