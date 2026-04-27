extends Label

class_name SliderValueLabel

@export var assigned_slider :HSlider
@export var value_suffix :String = ""
@export var display_as_int :bool = false
@export var value_multiplier :float = -1

## Custom string when slider is at minimum. Leave blanc to ignore.
@export var string_at_minimum :String = ""

## Custom string when slider is at maximum. Leave blanc to ignore.
@export var string_at_max :String = ""

func _ready() -> void:
	if assigned_slider:
		assigned_slider.value_changed.connect(_on_value_changed)
		_on_value_changed(assigned_slider.value)

func _on_value_changed(value: float) -> void:
	if value >= assigned_slider.max_value && string_at_max != "":
		text = string_at_max
		return
	
	if value <= assigned_slider.min_value && string_at_minimum != "":
		text = string_at_minimum
		return
	
	if value_multiplier != -1:
		value *= value_multiplier
	
	if display_as_int:
		text = str( int(value)) + value_suffix
	else:
		text = str(value) + value_suffix
