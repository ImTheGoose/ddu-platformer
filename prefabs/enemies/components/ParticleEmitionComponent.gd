extends Node

class_name ParticleEmitionComponent 

@export_group("Death Particles")
@export var health_compnent :HealthComponent
@export var death_particle_list :Array[GPUParticles2D]

@export_group("Movement Particles")
@export var movement_component :MovementComponent
@export var moving_particles :Array[GPUParticles2D]
@export var target_reached_particles :Array[GPUParticles2D]
@export var target_reached_collision_ray :RayCast2D

@export_group("Animation Particles")
@export var sprite_component :AnimatedSprite2D
@export var position_follows_flip :bool = true
var origin_positions :Array[Vector2] = []
@export var animation_name :String
@export var animation_frame :int
@export var frame_emitted_particles :Array[GPUParticles2D]

func _ready() -> void:
	if health_compnent:
		health_compnent.death.connect(_on_death)
	
	if movement_component:
		movement_component.target_reached.connect(_on_target_reached)
	
	if sprite_component:
		sprite_component.frame_changed.connect(_on_frame_changed)
		for p in frame_emitted_particles:
			origin_positions.append(p.position)
		

func _process(delta: float) -> void:
	if movement_component:
		if movement_component.is_moving():
			_emit_from_array(moving_particles, false)
		else:
			_emit_from_array(moving_particles, false, false)

func _on_target_reached() -> void:
	if target_reached_collision_ray:
		if not target_reached_collision_ray.is_colliding():
			return
	
	_emit_from_array(target_reached_particles)

func _on_frame_changed() -> void:
	if sprite_component.frame != animation_frame:
		return
	
	if sprite_component.animation != animation_name:
		return
	
	if position_follows_flip:
		for i in range(frame_emitted_particles.size()):
			var p :GPUParticles2D = frame_emitted_particles.get(i)
			if sprite_component.flip_h:
				p.position = origin_positions.get(i) 
				p.position.x = -p.position.x
			else:
				p.position = origin_positions.get(i)
	
	_emit_from_array(frame_emitted_particles)

func _on_death() -> void:
	_emit_from_array(death_particle_list)

func _emit_from_array(p_list: Array[GPUParticles2D], restart: bool = true, should_emit: bool = true) -> void:
	for p in p_list:
		if restart:
			p.restart()
		p.emitting = should_emit
