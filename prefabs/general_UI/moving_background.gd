extends TextureRect

@export var position_scale :float = 0.004

@export var shared_texture :SharedTexture

func _ready() -> void:
	shared_texture.texture_changed.connect(_on_texture_changed)
	_on_texture_changed(shared_texture.current_texture)

func _on_texture_changed(new_texture: Texture2D) -> void:
	texture = new_texture

func _process(delta: float) -> void:
	var mat: ShaderMaterial = material
	mat.set_shader_parameter("offset", get_viewport().get_camera_2d().global_position * position_scale)
