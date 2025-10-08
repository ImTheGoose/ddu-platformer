extends GameMenu


@onready var master_vol_slider = $PanelContainer/VBoxContainer/ScrollContainer/SettingsList/HBoxContainer/master_volume
@onready var music_vol_slider = $PanelContainer/VBoxContainer/ScrollContainer/SettingsList/HBoxContainer2/music_volume
@onready var fullscreen_toggle = $PanelContainer/VBoxContainer/ScrollContainer/SettingsList/fullscreen_toggle
@onready var particle_toggle = $PanelContainer/VBoxContainer/ScrollContainer/SettingsList/particles_toggle
@onready var vsync_toggle = $PanelContainer/VBoxContainer/ScrollContainer/SettingsList/vsync_toggle

func _ready() -> void:
	super()
	_load_config_variables()


func _load_config_variables():
	var video_settings = DataManager.get_video_settings()
	if video_settings.vsync == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	vsync_toggle.button_pressed = video_settings.vsync
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if video_settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen_toggle.button_pressed = video_settings.fullscreen
	particle_toggle.button_pressed = video_settings.particles_enabled
	
	var audio_settings = DataManager.get_audio_settings()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), audio_settings.master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), audio_settings.music_volume)
	master_vol_slider.value = audio_settings.master_volume
	music_vol_slider.value = audio_settings.music_volume

var res_list :Array[Vector2] = [Vector2(1280, 720), Vector2(1920, 1080), Vector2(2560, 1440), Vector2(3840, 2160)]

func _on_volume_value_changed(value: float) -> void:
	DataManager.save_audio_setting("master_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	pass # Replace with function body.

func _on_back_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.


func _on_clear_game_data_pressed() -> void:
	DataManager.clear_game_data()
	_load_config_variables()
	pass # Replace with function body.


func _on_music_volume_value_changed(value: float) -> void:
	DataManager.save_audio_setting("music_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	pass # Replace with function body.


func _on_keybinds_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("keybinding_menu")
	pass # Replace with function body.


func _on_check_box_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("fullscreen", toggled_on)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		if event.is_action("fullscreen_toggle"):
			var mode := DisplayServer.window_get_mode()
			var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
			fullscreen_toggle.button_pressed = is_window
			DataManager.save_video_setting("fullscreen", is_window)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_particles_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("particles_enabled", toggled_on)
	pass # Replace with function body.


func _on_vsync_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("vsync", toggled_on)
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	pass # Replace with function body.
