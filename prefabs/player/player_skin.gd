extends AnimatedSprite2D

@export var player :Player

@onready var skin_sprites :Dictionary[String, SpriteFrames]= {
	"Osvald": preload("uid://b4t3asxpw884d"),
	"Tiki": preload("uid://copebinntgo64"),
	"Castro": preload("uid://blcdmj7rjkeo3"),
	"Edward": preload("uid://dvv7gt1jhi3uo"),
}

func _ready() -> void:
	var skin_name :String = DataManager.get_value("selected_skin")
	sprite_frames = skin_sprites[skin_name]

func _process(delta: float) -> void:
	if !player:
		return
	
	if player.velocity.x > 0:
		flip_h = false
	elif player.velocity.x < 0:
		flip_h = true
	
	if player.state == Player.PlayerState.IDLE:
		play("Idle")
	elif player.state == Player.PlayerState.RUNNING:
		play("Run")
	elif player.state == Player.PlayerState.ON_WALL:
		play("Wall_Jump")
	elif player.state == Player.PlayerState.IN_AIR:
		if player.velocity.y > 0:
			play("Fall")
		elif player.double_jumped:
			play("Double_Jump")
		else:
			play("Jump")
		
