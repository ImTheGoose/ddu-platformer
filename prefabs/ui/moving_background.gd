extends TextureRect

@export var position_scale = 0.004

var background_textures :Dictionary = {
	"Blue": preload("res://assets/pixel_adventure_assets/Background/Blue.png"),
	"Brown": preload("res://assets/pixel_adventure_assets/Background/Brown.png"),
	"Gray": preload("res://assets/pixel_adventure_assets/Background/Gray.png"),
	"Green": preload("res://assets/pixel_adventure_assets/Background/Green.png"),
	"Pink": preload("res://assets/pixel_adventure_assets/Background/Pink.png"),
	"Red": preload("res://assets/pixel_adventure_assets/Background/Red.png"),
	"Black": preload("res://assets/pixel_adventure_assets/Background/Black.png"),
}

func _process(delta: float) -> void:
	var theme_name = DataManager.get_value("selected_accent")
	
	var mat: ShaderMaterial = material
	mat.set_shader_parameter("offset", global_position * position_scale)
	
	texture = background_textures[theme_name]
