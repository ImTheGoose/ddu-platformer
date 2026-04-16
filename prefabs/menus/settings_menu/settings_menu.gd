extends GameMenu


@onready var master_vol_slider :HSlider = %master_volume
@onready var music_vol_slider :HSlider = %music_volume
@onready var max_fps_slider :HSlider= %fps_limit
@onready var camera_shake_toggle: CheckBox = %camera_shake_toggle
@onready var fps_toggle: CheckBox = %fps_toggle
@onready var fullscreen_toggle :CheckBox = %fullscreen_toggle
@onready var particle_amount_dropdown: OptionButton = %particle_amount_dropdown
@onready var vsync_toggle :CheckBox = %vsync_toggle
@onready var skip_transitions_toggle :CheckBox = %skip_transitions_toggle
@onready var clear_game_data: Button = %clear_game_data



func _ready() -> void:
	super()
	_load_config_variables()
	var video_settings :Dictionary = DataManager.get_video_settings()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if video_settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	master_vol_slider.value_changed.connect(_on_volume_value_changed)
	music_vol_slider.value_changed.connect(_on_music_volume_value_changed)
	max_fps_slider.value_changed.connect(_on_fps_limit_value_changed)
	fps_toggle.toggled.connect(_on_fps_toggled)
	camera_shake_toggle.toggled.connect(_on_camera_shake_toggled)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggle_toggled)
	particle_amount_dropdown.item_selected.connect(_on_particle_amount_selected)
	vsync_toggle.toggled.connect(_on_vsync_toggle_toggled)
	skip_transitions_toggle.toggled.connect(_on_skip_transition_toggle_toggled)
	

func _on_show() -> void:
	_load_config_variables()
	
	if MenuHandler.is_game_visible() or multiplayer.multiplayer_peer is not OfflineMultiplayerPeer:
		clear_game_data.visible = false
		clear_game_data.disabled = true
	else:
		clear_game_data.visible = true
		clear_game_data.disabled = false

func _load_config_variables() -> void:
	var video_settings :Dictionary = DataManager.get_video_settings()
	if video_settings.get("vsync", true) == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	skip_transitions_toggle.button_pressed = video_settings.get("skip_transitions", false)
	camera_shake_toggle.button_pressed = video_settings.get("camera_shake_enabled", true)
	_on_fps_limit_value_changed(video_settings.get("max_fps", 600))
	max_fps_slider.value = video_settings.get("max_fps", 600)
	vsync_toggle.button_pressed = video_settings.get("vsync", true)
	
	fullscreen_toggle.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else false
	particle_amount_dropdown.selected = particle_amount_dropdown.get_item_index(video_settings.get("particle_amount", ToggleableParticle.ParticleAmount.ALL))
	
	var audio_settings :Dictionary = DataManager.get_audio_settings()
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), audio_settings.get("master_volume", 0.5))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), audio_settings.get("music_volume", 0.5))
	master_vol_slider.value = audio_settings.get("master_volume", 0)
	music_vol_slider.value = audio_settings.get("music_volume", 0)

func _on_volume_value_changed(value: float) -> void:
	DataManager.save_audio_setting("master_volume", value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
	pass # Replace with function body.

func _on_music_volume_value_changed(value: float) -> void:
	DataManager.save_audio_setting("music_volume", value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value)


func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("fullscreen", toggled_on)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_particle_amount_selected(index: int) -> void:
	DataManager.save_video_setting("particle_amount", particle_amount_dropdown.get_item_id(index))
	
func _on_skip_transition_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("skip_transitions", toggled_on)


func _on_vsync_toggle_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("vsync", toggled_on)
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_fps_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("show_fps", toggled_on)

func _on_fps_limit_value_changed(value: float) -> void:
	DataManager.save_video_setting("max_fps", value)
	if value >= max_fps_slider.max_value:
		Engine.max_fps = 0
	else:
		Engine.max_fps = int(value)

func _on_camera_shake_toggled(toggled_on: bool) -> void:
	DataManager.save_video_setting("camera_shake_enabled", toggled_on)

func _on_back_pressed() -> void:
	MenuHandler.change_menu(MenuHandler.get_previous_menu())

func _on_keybinds_pressed() -> void:
	MenuHandler.change_menu("keybinding_menu")


func _on_clear_game_data_pressed() -> void:
	MenuHandler.change_menu("reset_game_menu")
