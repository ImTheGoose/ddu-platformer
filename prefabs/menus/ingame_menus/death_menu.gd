extends GameMenu

@export var time_bbcode :String = "[img]res://assets/icons/time (16x16).png[/img]Time alive - "
@export var apple_bbcode :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]Apples collected - "
@export var highscore_suffix :String = " (new highscore)"

var new_highscore_sound :AudioStreamMP3 = preload("uid://dp8k0xj5ljst1")
@onready var stat_text_node :RichTextLabel = %stat_label
@export var time_highscore_particles :Array[GPUParticles2D] = []
@export var apple_highscore_particles :Array[GPUParticles2D] = []


func _on_show() -> void:
	_refresh_stat_text()


func _refresh_stat_text() -> void:
	var text :String = ""
	var time_alive :Variant = StatisticManager.get_value("time_alive")
	if time_alive >= DataManager.get_value("statistics")["time_highscore"]:
		text += time_bbcode + TimeFormat.get_time_string(time_alive) + highscore_suffix + "[br]"
		for p in time_highscore_particles:
			p.visible = true
			p.restart()
			p.emitting = true
	else:
		text += time_bbcode + TimeFormat.get_time_string(time_alive) +  "[br]"
		for p in time_highscore_particles:
			p.visible = false
	
	var apples_collected :int = StatisticManager.get_value("apples_collected")
	
	if apples_collected >= DataManager.get_value("statistics")["apple_highscore"]:
		text += apple_bbcode + str( int(apples_collected)) + highscore_suffix
		for p in apple_highscore_particles:
			p.visible = true
			p.restart()
			p.emitting = true
	else:
		text += apple_bbcode + str( int(apples_collected))
		for p in apple_highscore_particles:
			p.visible = false
	
	if text.contains("highscore"):
		AudioManager.play_global_sound(new_highscore_sound, -3)
	
	stat_text_node.text = text

func _on_play_again_pressed() -> void:
	GameManager.reset_game()
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	GameManager.quit_to_main()
	pass # Replace with function body.
