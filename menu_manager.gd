extends Control

#ALERT This system is temporary and will be depricated soon.

@onready var main_menu := $MainMenu
@onready var pause_menu := $PauseMenu
@onready var death_menu := $DeathMenu
@export var map_gen :Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") && GameManager.is_game_running():
		_show_menu(pause_menu)
		GameManager.pause_game(true)


func _hide_menus():
	main_menu.visible = false
	main_menu.set_process(false)
	pause_menu.visible = false
	pause_menu.set_process(false)
	death_menu.visible = false
	death_menu.set_process(false)

func _show_menu(menu):
	menu.visible = true
	menu.set_process(true)

func _on_game_stop():
	_show_menu(death_menu)
	

func _ready() -> void:
	GameManager.on_stop_game.connect(_on_game_stop)
	GameManager.on_reset_game.connect(_hide_menus)
	_hide_menus()
	_show_menu(main_menu)
	map_gen.visible = false
	GameManager.pause_game(true)

func _on_start_game_pressed() -> void:
	_hide_menus()
	map_gen.visible = true
	GameManager.pause_game(false)
	GameManager.start_game()
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	GameManager.quit_game()
	pass # Replace with function body.


func _on_continue_game_pressed() -> void:
	_hide_menus()
	GameManager.pause_game(false)
	pass # Replace with function body.


func _on_restart_game_pressed() -> void:
	_hide_menus()
	GameManager.reset_game()
	GameManager.pause_game(false)
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	_hide_menus()
	GameManager.reset_game()
	GameManager.pause_game(true)
	map_gen.visible = false
	_show_menu(main_menu)
	pass # Replace with function body.


func _on_play_again_pressed() -> void:
	_hide_menus()
	GameManager.reset_game()
	GameManager.pause_game(false)
	pass # Replace with function body.
