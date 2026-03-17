extends AnimatedSprite2D

@export var chosen_skin_string :String = "Osvald"
@export var chosen_outline_color :Color = Color.BLACK
@export var player_controller :Player
@onready var skin_sprites :Dictionary[String, SpriteFrames]= {
	"Osvald": preload("uid://b4t3asxpw884d"),
	"Tiki": preload("uid://copebinntgo64"),
	"Castro": preload("uid://blcdmj7rjkeo3"),
	"Edward": preload("uid://dvv7gt1jhi3uo"),
}

func _ready() -> void:
	GameManager.spawn_player.connect(_on_spawn_player)
	
	if is_multiplayer_authority():
		var skin_name :String = DataManager.get_value("selected_skin")
		chosen_skin_string = skin_name
		chosen_outline_color = Color(randf(),randf(),randf(),0.85)

func _process(delta: float) -> void:
	sprite_frames = skin_sprites[chosen_skin_string]
	get_material().set_shader_parameter("color", chosen_outline_color)
	
	if player_controller.dead:
		return
	
	if player_controller.velocity.x > 0:
		flip_h = false
	elif player_controller.velocity.x < 0:
		flip_h = true
		

func _on_spawn_player(gpos: Vector2, peer_id: int) -> void:
	if is_multiplayer_authority():
		var skin_name :String = DataManager.get_value("selected_skin")
		chosen_skin_string = skin_name
		chosen_outline_color = Color(randf(),randf(),randf(),0.85)
	
