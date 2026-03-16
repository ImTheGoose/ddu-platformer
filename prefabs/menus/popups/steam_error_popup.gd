extends GameMenu

@onready var error_label :RichTextLabel = %error_description
const ERROR_TEXT :String = "An issue occured while initialising steam: "

const ERROR_STRING_CODES :Dictionary[Steam.SteamAPIInitResult, String] = {
	Steam.STEAM_API_INIT_RESULT_OK : "No issues detected?",
	Steam.STEAM_API_INIT_RESULT_NO_STEAM_CLIENT : "Steam client not detected.",
	Steam.STEAM_API_INIT_RESULT_FAILED_GENERIC : "Unknown Error.",
	Steam.STEAM_API_INIT_RESULT_VERSION_MISMATCH : "Steam client out of date.",
}

func _on_show() -> void:
	_refresh_description()

func _refresh_description() -> void:
	var reason :Dictionary = Steam.get_steam_init_result()
	error_label.text = ERROR_TEXT + ERROR_STRING_CODES[reason.status]
	


func _on_cancel_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
