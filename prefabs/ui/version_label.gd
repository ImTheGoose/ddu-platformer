extends Label

func _ready() -> void:
	text = "V" + str(ProjectSettings.get_setting("application/config/version"))
