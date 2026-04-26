extends AnimatedSprite2D

class_name AnimatedShadowSprite2D 

@export var entity_node :Entity
@export var reference_sprite :AnimatedSprite2D
@export var shadow_dir :Vector2 = Vector2(-1, 1)

func _ready() -> void:
	if not sprite_frames:
		return
	
	if reference_sprite:
		if reference_sprite is EnemySpriteComponent:
			if not entity_node:
				entity_node = reference_sprite.entity_node
			
			reference_sprite.flipped_h.connect(sync_animation_to_reference)
		
		reference_sprite.frame_changed.connect(_on_frame_changed)
		reference_sprite.ready.connect(sync_animation_to_reference)
		reference_sprite.animation_changed.connect(_on_animation_changed)
		sprite_frames = reference_sprite.sprite_frames
		visible = true
		show_behind_parent = true
		modulate = Color8(0,0,0, 50)
		#position += shadow_dir
		sync_animation_to_reference()

	if entity_node:
		entity_node.enabled.connect(sync_animation_to_reference)

func _on_frame_changed() -> void:
	if reference_sprite.animation != animation:
		sync_animation_to_reference()
	elif reference_sprite.frame != frame or reference_sprite.frame_progress != frame_progress:
		set_frame_and_progress(reference_sprite.frame, reference_sprite.frame_progress)

func _on_animation_changed() -> void:
	sync_animation_to_reference()
	return

func sync_animation_to_reference() -> void:
	position = Vector2.ZERO
	var rot_angle: float = 0.0
	if entity_node:
		if not entity_node.block_rotation:
			if entity_node.enabled_modifiers.has(Entity.EntityModifiers.ROTATE_90):
				rot_angle = -90
			if entity_node.enabled_modifiers.has(Entity.EntityModifiers.ROTATE_180):
				rot_angle = 180
			if entity_node.enabled_modifiers.has(Entity.EntityModifiers.ROTATE_270):
				rot_angle = -270
	position += shadow_dir.rotated(deg_to_rad(rot_angle))
	offset = reference_sprite.offset
	flip_h = reference_sprite.flip_h
	flip_v = reference_sprite.flip_v
	animation = reference_sprite.animation
	set_frame_and_progress(reference_sprite.frame, reference_sprite.frame_progress)
	play()
	return
