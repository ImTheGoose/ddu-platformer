extends AnimatedSprite2D


@onready var skin_sprites :Dictionary[String, SpriteFrames]= {
	"Osvald": preload("uid://b4t3asxpw884d"),
	"Tiki": preload("uid://copebinntgo64"),
	"Castro": preload("uid://blcdmj7rjkeo3"),
	"Edward": preload("uid://dvv7gt1jhi3uo"),
}

func _ready() -> void:
	var skin_name :String = DataManager.get_value("selected_skin")
	sprite_frames = skin_sprites[skin_name]
