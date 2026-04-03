extends Entity

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var area_2d: Area2D = %Area2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@export var path_detection_component :TrapPathDetectionComponent
@export_range(-1000, 1000, 1.0) var area_velocity :float = -20.0
var default_shape :RectangleShape2D

var default_particle_amount :int = 0
var default_particle_lifetime :float = 1.0
var default_particle_speedscale :float = 1.0


func _ready() -> void:
	default_particle_amount = gpu_particles_2d.amount
	default_particle_lifetime = gpu_particles_2d.lifetime
	default_shape = collision_shape_2d.shape
	animated_sprite_2d.play("On")
	path_detection_component.path_changed.connect(_on_path_changed)
	
	_on_path_changed()
	
func _on_path_changed() -> void:
	var target_point :Vector2 = path_detection_component.get_detected_position()
	var distance :float = global_position.distance_to(target_point)

	var new_shape: RectangleShape2D = RectangleShape2D.new()
	new_shape.size.y = distance / global_scale.y
	
	if target_point == Vector2.ZERO:
		new_shape = default_shape
	

	collision_shape_2d.shape = new_shape
	collision_shape_2d.position.y = -new_shape.size.y / 2
	
	var shape_scale :float = new_shape.size.y / default_shape.size.y
	gpu_particles_2d.amount = int(default_particle_amount * shape_scale)
	gpu_particles_2d.lifetime = default_particle_lifetime * shape_scale
	gpu_particles_2d.visibility_rect = new_shape.get_rect()
	
	
	return

func _on_reset() -> void:
	collision_shape_2d.shape = default_shape
	

func _physics_process(delta: float) -> void:
	for body in area_2d.get_overlapping_bodies():
		if body is Player:
			if body.is_multiplayer_authority():
				var dir_up :Vector2 = Vector2.UP.rotated(global_rotation).normalized()

				var velocity_up :float = body.velocity.dot(dir_up)

				if velocity_up < area_velocity:
					var difference :float = area_velocity - velocity_up
					body.velocity += dir_up * difference
				
