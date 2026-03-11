extends Control

const ALERT_CARD = preload("uid://dl0dxwej5vhwm")
@export var max_active_alerts :int = 4
@export var padding :float = 3.0
@export_range(0, 3, 0.1, "or_greater") var reorder_animation_seconds :float = 0.7

func _ready() -> void:
	Alerts.new_alert.connect(_on_new_alert)
	child_entered_tree.connect(_on_child_entered_tree)

func _on_new_alert(alert : Alert) -> void:
	_add_alert_card(alert)
	_tween_offset_position()

func _on_child_entered_tree(node: Node):
	_tween_offset_position()

func _add_alert_card(alert : Alert) -> void:
	var card = ALERT_CARD.instantiate()
	card.alert = alert
	add_child(card)

func _tween_offset_position() -> void:
	var tween = get_tree().create_tween().bind_node(self).set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	for child : Control in get_children():
		if child.size.x > custom_minimum_size.x: 
			custom_minimum_size.x = child.size.x
		
		if child.get_index() == get_child_count():
			return
		
		var negative_index = get_child_count() - child.get_index() - 1
		
		tween.tween_property(child, "position:y", (child.size.y + padding) * negative_index, reorder_animation_seconds)
		if negative_index >= max_active_alerts:
			child.kill_alert()
	
	tween.play()
