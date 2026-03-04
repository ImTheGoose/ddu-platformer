extends Node

@onready var ui_click_sound :AudioStreamOggVorbis= preload('uid://cpx7rwjnsv6c')

var playback:AudioStreamPlaybackPolyphonic

func _enter_tree() -> void:
	# Create an audio player
	var player :AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream :AudioStreamPolyphonic = AudioStreamPolyphonic.new()
	stream.polyphony = 64
	player.max_polyphony = 64
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func play_global_sound(sound: AudioStream, volume: float) -> void:
	playback.play_stream(sound, 0, volume, randf_range(0.9, 1.1), AudioServer.PLAYBACK_TYPE_DEFAULT, "SFX")
	

func _on_node_added(node: Node) -> void:
	if node is Button:
		node.pressed.connect(_play_pressed)
		
func _play_pressed() -> void:
	playback.play_stream(ui_click_sound, 0, 0, randf_range(0.9, 1.1), AudioServer.PLAYBACK_TYPE_DEFAULT, "SFX")
