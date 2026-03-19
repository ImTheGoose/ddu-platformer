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

var player_info :PlayerInfo

func _ready() -> void:
	GameManager.spawn_player.connect(_on_spawn_player)
	player_info = Lobby.get_player_info(get_multiplayer_authority())
	player_info.cosmetics_changed.connect(_on_cosmetics_changed)
	refresh_cosmetics()

func _process(delta: float) -> void:
	if !player_info or player_info.PEER_ID != get_multiplayer_authority():
		if player_info && player_info.cosmetics_changed.is_connected(_on_cosmetics_changed):
			player_info.cosmetics_changed.disconnect(_on_cosmetics_changed)
		player_info = Lobby.get_player_info(get_multiplayer_authority())
		player_info.cosmetics_changed.connect(_on_cosmetics_changed)
	
	if player_controller.dead:
		return
	
	if player_controller.velocity.x > 0:
		flip_h = false
	elif player_controller.velocity.x < 0:
		flip_h = true

func refresh_cosmetics() -> void:
	sprite_frames = skin_sprites[player_info.SELECTED_SKIN_NAME]
	get_material().set_shader_parameter("color", Color(player_info.SELECTED_OUTLINE_HEX))

func _on_cosmetics_changed() -> void:
	refresh_cosmetics()
	return

func _on_spawn_player(gpos: Vector2, peer_id: int) -> void:
	refresh_cosmetics()
	
