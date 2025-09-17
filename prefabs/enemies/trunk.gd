extends PlayerDetectingEnemy

@export var projectile :PackedScene
@onready var projectile_spawn :Node2D = $ProjectileSpawn

func _attack():
	super()
	
	var p: Projectile = projectile.instantiate()
	p.direction = _get_direction()
	add_sibling(p)
	var pos = projectile_spawn.position
	
	projectile_spawn.position.x = pos.x * -_get_direction().x
	
	p.global_position = projectile_spawn.global_position 
	
	projectile_spawn.position = pos
