extends TextureRect

@export var position_scale :float = 0.004

var background_textures :Dictionary[String, CompressedTexture2D] = {
	"Blue": preload("uid://hp36vp4rgh30"),
	"Brown": preload("uid://djvdn4edth2po"),
	"Gray": preload("uid://ob77turt7mcj"),
	"Green": preload("uid://cfyrwu5jj40ea"),
	"Pink": preload("uid://bxwx3outaa45n"),
	"Red": preload("uid://cyo6dhvlxakth"),
	"Black": preload("uid://cjnmrel60l871"),
}

func _process(delta: float) -> void:
	var theme_name :String = DataManager.get_value("selected_accent")
	
	var mat: ShaderMaterial = material
	mat.set_shader_parameter("offset", global_position * position_scale)
	
	texture = background_textures[theme_name]
