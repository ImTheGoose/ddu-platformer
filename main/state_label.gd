extends RichTextLabel

func _process(delta: float) -> void:
	text = "State: %s" % GameManager.STATE.keys()[GameManager.get_state()]
