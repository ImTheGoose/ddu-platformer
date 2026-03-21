extends GameMenu

@onready var play_again_button: Button = %play_again_button
@onready var return_to_lobby: Button = %return_to_lobby
@onready var quit_to_main: Button = %quit_to_main

func _on_show() -> void:
	if multiplayer.is_server():
		play_again_button.visible = true
		play_again_button.disabled = false
		return_to_lobby.visible = true
		return_to_lobby.disabled = false
		quit_to_main.visible = false
		quit_to_main.disabled = true
	else:
		play_again_button.visible = false
		play_again_button.disabled = true
		return_to_lobby.visible = false
		return_to_lobby.disabled = true
		quit_to_main.visible = true
		quit_to_main.disabled = false


func _on_play_again_button_pressed() -> void:
	GameManager.prepare_game()


func _on_return_to_lobby_pressed() -> void:
	GameManager.return_to_lobby()

func _on_settings_button_pressed() -> void:
	MenuHandler.change_menu("settings_menu", true)


func _on_customize_button_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu", true)


func _on_quit_to_main_pressed() -> void:
	GameManager.quit_to_main()
