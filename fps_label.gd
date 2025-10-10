extends RichTextLabel

@export var bbcode :String = "FPS: "

func _process(delta: float) -> void:
	visible = DataManager.get_video_settings()["show_fps"]
	text = bbcode + str( int(Engine.get_frames_per_second()))
	
