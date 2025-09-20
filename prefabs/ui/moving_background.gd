extends TextureRect

@export var position_scale = 0.004

var background_textures :Dictionary = {
	"Blue": preload("res://asset_pack/Background/Blue.png"),
	"Brown": preload("res://asset_pack/Background/Brown.png"),
	"Gray": preload("res://asset_pack/Background/Gray.png"),
	"Green": preload("res://asset_pack/Background/Green.png"),
	"Pink": preload("res://asset_pack/Background/Pink.png"),
	"Purple": preload("res://asset_pack/Background/Purple.png"),
	"Yellow": preload("res://asset_pack/Background/Yellow.png"),
}

func _process(delta: float) -> void:
	var video_settings = DataManager.get_video_settings()
	var theme_name = video_settings.color_theme
	
	var mat: ShaderMaterial = material
	mat.set_shader_parameter("offset", global_position * position_scale)
	
	texture = background_textures[theme_name]
