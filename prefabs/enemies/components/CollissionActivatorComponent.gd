extends RayCast2D

class_name CollissionActivatorComponent 

@export var hit_area :HitArea

func _process(delta: float) -> void:
	if not hit_area:
		return
	
	if is_colliding():
		hit_area.monitorable = true
		hit_area.monitoring = true
		hit_area.visible = true
	else:
		hit_area.monitorable = false
		hit_area.monitoring = false
		hit_area.visible = false
