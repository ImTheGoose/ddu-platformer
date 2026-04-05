extends Node2D

class_name SinusOffsetComponent 

@export var entity_node :Entity
@export var health_component: HealthComponent
@export_range(0,16, 1.0) var offset_amount :float = 0.0
@export_range(0, 10, 0.1) var offset_speed_scale :float = 5.0
@export var offset_direction :Vector2 = Vector2(0, 1)
var origin_position :Vector2 = position
var seconds_since_spawn :float = 0.0

func _ready() -> void:
	origin_position = position
	if entity_node:
		entity_node.entity_reset.connect(_on_entity_reset)

func _process(delta: float) -> void:
	seconds_since_spawn += delta
	var offset_wave :float = sin(seconds_since_spawn * offset_speed_scale)
	position = origin_position + offset_wave * offset_amount * offset_direction

func _on_entity_reset() -> void:
	position = origin_position
	seconds_since_spawn = 0.0
