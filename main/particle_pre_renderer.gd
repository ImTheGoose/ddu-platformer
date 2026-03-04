extends Node2D

@export var particle_nodes :Array[PackedScene]
@export var seconds_before_clear :float = 10
var seconds_passed :float = 0

func _process(delta: float) -> void:
	if get_child_count() <= 0:
		return
	
	seconds_passed += delta
	if seconds_passed >= seconds_before_clear:
		for c: Node in get_children():
			c.queue_free()
		
	

func _ready() -> void:
	for node: PackedScene in particle_nodes:
		var p :GPUParticles2D = node.instantiate()
		p.emitting = true
		add_child(p)
