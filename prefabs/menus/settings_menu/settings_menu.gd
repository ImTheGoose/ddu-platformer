extends GameMenu


@onready var master_vol_slider :HSlider = %master_volume
@onready var music_vol_slider :HSlider = %music_volume
@onready var max_fps_slider :HSlider= %fps_limit
@onready var fps_toggle :CheckBox = %fps_toggle
@onready var fullscreen_toggle :CheckBox = %fullscreen_toggle
@onready var particle_toggle :CheckBox = %particles_toggle
@onready var vsync_toggle :CheckBox = %vsync_toggle



func _ready() -> void:
	super()
	_load_config_variables()
	master_vol_slider.value_changed.connect(_on_volume_value_changed)
	music_vol_slider.value_changed.connect(_on_music_volume_value_changed)
	max_fps_slider.value_changed.connect(_on_fps_limit_value_changed)
	fps_toggle.toggled.connect(_on_fps_toggle_toggled)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggle_toggled)
	particle_toggle.toggled.connect(_on_particles_toggle_toggled)
	vsync_toggle.toggled.connect(_on_vsync_toggle_toggled)
	

func _on_show() -> void:
	_load_config_variables()

func _load_config_variables() -> void:
	var video_settings :Dictionary = DataManager.get_video_settings()
	if video_settings.vsync == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	fps_toggle.button_pressed = video_settings.show_fps
	_on_fps_limit_value_changed(video_settings.max_fps)
	max_fps_slider.value = video_settings.max_fps
	vsync_toggle.button_pressed = video_settings.vsync
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if video_settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen_toggle.button_pressed = video_settings.fullscreen
	particle_toggle.button_pressed = video_settings.particles_enabled
	
	var audio_settings :Dictionary = DataManager.get_audio_settings()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), audio_settings.master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), audio_settings.music_volume)
	master_vol_slider.value = audio_settings.master_volume
	music_vol_slider.value = audio_settings.music_volume

func _on_volume_value_changed(value: float) -> void:
	DataManager.save_audio_setting("master_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	pass # Replace with function body.

func _on_music_volume_value_changed(value: float) -> void:
	DataManager.save_audio_setting("music_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)


func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("fullscreen", toggled_on)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	

func _on_particles_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("particles_enabled", toggled_on)
	

func _on_vsync_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("vsync", toggled_on)
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_fps_limit_value_changed(value: float) -> void:
	DataManager.save_video_setting("max_fps", value)
	if value >= max_fps_slider.max_value:
		Engine.max_fps = 0
	else:
		Engine.max_fps = value

func _on_fps_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("show_fps", toggled_on)


func _on_back_pressed() -> void:
	MenuHandler.change_menu("main_menu")
	pass # Replace with function body.


func _on_keybinds_pressed() -> void:
	MenuHandler.change_menu("keybinding_menu")


func _on_clear_game_data_pressed() -> void:
	MenuHandler.change_menu("reset_game_menu")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		if event.is_action("fullscreen_toggle"):
			var mode := DisplayServer.window_get_mode()
			var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
			fullscreen_toggle.button_pressed = is_window
			DataManager.save_video_setting("fullscreen", is_window)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
