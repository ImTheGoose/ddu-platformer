extends Resource

class_name SharedTexture 

signal texture_changed(new_texture: Texture2D)

@export var current_texture: Texture2D:
	set(value):
		current_texture = value
		texture_changed.emit(value)
