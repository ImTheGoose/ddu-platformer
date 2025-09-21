extends PlayerDetectingEnemy

@export var projectile :PackedScene
@onready var projectile_spawn :Node2D = $ProjectileSpawn
@onready var audio_on_fire = preload("res://assets/audio/sfx/tree_sound.mp3")

func _attack():
	super()
	AudioManager.play_global_sound(audio_on_fire, -3)
	
	var p: Projectile = projectile.instantiate()
	p.direction = _get_direction()
	add_sibling(p)
	var pos = projectile_spawn.position
	
	projectile_spawn.position.x = pos.x * -_get_direction().x
	
	p.global_position = projectile_spawn.global_position 
	
	projectile_spawn.position = pos
