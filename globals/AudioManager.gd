extends Node

@onready var ui_click_sound :AudioStreamOggVorbis= preload('uid://cpx7rwjnsv6c')

var playback:AudioStreamPlaybackPolyphonic

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _enter_tree() -> void:
	# Create an audio player
	var player :AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream :AudioStreamPolyphonic = AudioStreamPolyphonic.new()
	stream.polyphony = 64
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()
	
	get_tree().node_added.connect(_on_node_added)

#Depricated
func play_global_sound(sound: AudioStream, linear_volume: float) -> void:
	playback.play_stream(sound, 0, linear_volume, randf_range(0.9, 1.1), AudioServer.PLAYBACK_TYPE_DEFAULT, "SFX")

func play_global_pitched(sound: AudioStream, linear_volume: float) -> void:
	play_global(sound, linear_volume, randf_range(0.9, 1.1))

func play_global(sound: AudioStream, linear_volume: float, pitch: float = 1.0) -> void:
	playback.play_stream(sound, 0, linear_to_db(linear_volume), pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, "SFX")

func play_random_pitched(sounds: Dictionary[AudioStream, float]) -> void:
	play_random(sounds, randf_range(0.9, 1.1))

func play_random(sounds: Dictionary[AudioStream, float], pitch: float = 1.0) -> void:
	var rand :int = randi_range(0, sounds.size())
	for i in sounds.size():
		if i == rand:
			var key :AudioStream = sounds.keys().get(i)
			play_global(key, sounds.get(key, 1.0))
		

func _on_node_added(node: Node) -> void:
	if node is Button:
		node.pressed.connect(_play_pressed)
		
func _play_pressed() -> void:
	play_global_pitched(ui_click_sound, 1.0)
