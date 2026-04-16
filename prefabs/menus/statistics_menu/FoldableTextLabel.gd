extends StatRichLabel

class_name FoldableTextLabel 


const arrow_bbcode :Dictionary[bool, String] = {
	true : "[img]res://assets/icons/arrow_right (16x16).png[/img]",
	false : "[img]res://assets/icons/arrow_down (16x16).png[/img]",
}

@export var child_control :Control

signal fold_updated(is_folded: bool)

var folded :bool = false

func _ready() -> void:
	super()
	bbcode_spacing = ""
	bbcode_enabled = true
	fit_content = true
	toggle_fold()

func _gui_input(event: InputEvent) -> void:
	if has_focus():
		if not event.is_pressed():
				return

		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_on_pressed()
				return
		
		if event.is_action("ui_accept"):
			_on_pressed()
			return

func _on_pressed() -> void:
	toggle_fold()
	Audio._play_pressed()

func toggle_fold() -> void:
	folded = !folded
	if child_control:
		child_control.visible = !folded
	original_bbcode = arrow_bbcode[folded]
	fold_updated.emit(folded)
	_refresh_label()
	return
