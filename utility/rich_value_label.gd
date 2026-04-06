extends RichTextLabel

@export var BB_Code :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]"
@export var data_key :String = "money"

func _process(delta: float) -> void:
	_update_text()

func _update_text() -> void:
	var value :float = DataManager.get_value(data_key)
	text = BB_Code + str(int(value))
