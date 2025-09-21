extends AnimatedSprite2D

@onready var skin_sprites = {
	"Osvald": preload("res://ressources/osvald_spriteframes.tres"),
	"Tiki": preload("res://ressources/tiki_spriteframes.tres"),
	"Castro": preload("res://ressources/castro_spriteframes.tres"),
	"Edward": preload("res://ressources/edward_spriteframes.tres"),
}


func _ready() -> void:
	var skin_name = DataManager.get_value("selected_skin")
	sprite_frames = skin_sprites[skin_name]
