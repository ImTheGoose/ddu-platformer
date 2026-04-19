extends AnimatedSprite2D

class_name AnimatedShadowSprite2D 

@export var entity_node :Entity
@export var reference_sprite :AnimatedSprite2D
@export var shadow_dir :Vector2 = Vector2(-1, 1)

func _ready() -> void:
	if not sprite_frames:
		return
	
	if entity_node:
		entity_node.enabled.connect(sync_animation_to_reference)
	
	if reference_sprite:
		if reference_sprite is EnemySpriteComponent:
			reference_sprite.flipped_h.connect(sync_animation_to_reference)
			
		reference_sprite.ready.connect(sync_animation_to_reference)
		reference_sprite.animation_changed.connect(_on_animation_changed)
		sprite_frames = reference_sprite.sprite_frames
		visible = true
		show_behind_parent = true
		modulate = Color8(0,0,0, 50)
		position += shadow_dir
		sync_animation_to_reference()

func _on_animation_changed() -> void:
	sync_animation_to_reference()
	return

func sync_animation_to_reference() -> void:
	position = Vector2.ZERO
	global_position += shadow_dir
	offset = reference_sprite.offset
	flip_h = reference_sprite.flip_h
	flip_v = reference_sprite.flip_v
	animation = reference_sprite.animation
	set_frame_and_progress(reference_sprite.frame, reference_sprite.frame_progress)
	play()
	return
