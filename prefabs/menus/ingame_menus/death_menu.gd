extends GameMenu

@export var time_bbcode :String = "[img]res://assets/icons/time (16x16).png[/img]Time alive - "
@export var height_bbcode :String = "[img]res://assets/pixel_adventure_assets/Other/dust (16x16).png[/img] Height Reached - "
@export var apple_bbcode :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]Apples collected - "
@export var highscore_suffix :String = " (new highscore)"

var new_highscore_sound :AudioStreamMP3 = preload("uid://dp8k0xj5ljst1")
@onready var stat_text_node :RichTextLabel = %stat_label
@export var time_highscore_particles :Array[GPUParticles2D] = []

@onready var play_again_button :Button = %play_again_button
@onready var main_menu_button :Button = %back_button
@onready var back_to_lobby :Button = %back_to_lobby


func _on_show() -> void:
	_refresh_stat_text()
	if !multiplayer.is_server():
		play_again_button.visible = false
		play_again_button.disabled = true
		main_menu_button.visible = true
		main_menu_button.disabled = false
		back_to_lobby.disabled = true
		back_to_lobby.visible = false
	else:
		if multiplayer.get_peers().size() < 1:
			main_menu_button.visible = true
			main_menu_button.disabled = false
			back_to_lobby.disabled = true
			back_to_lobby.visible = false
		else:
			main_menu_button.visible = false
			main_menu_button.disabled = true
			back_to_lobby.disabled = false
			back_to_lobby.visible = true
	
		play_again_button.visible = true
		play_again_button.disabled = false

func _refresh_stat_text() -> void:
	var text :String = ""
	var time_alive :Variant = Stats.get_recording_value(Stats.StatType.TIME_ALIVE)
	if time_alive >= Stats.get_float_stat(Stats.get_time_highscore_type()) && not GameManager.is_playing_level():
		text += time_bbcode + Format.get_time_string(time_alive) + highscore_suffix + "[br]"
		for p in time_highscore_particles:
			p.visible = true
			p.restart()
			p.emitting = true
	else:
		text += time_bbcode + Format.get_time_string(time_alive) +  "[br]"
		for p in time_highscore_particles:
			p.visible = false
	
	var height_reached :Variant = Stats.get_recording_value(Stats.StatType.HEIGHT_REACHED)
	if height_reached >= Stats.get_float_stat(Stats.get_height_highscore_type()) && not GameManager.is_playing_level():
		text += height_bbcode + Format.get_height_string(height_reached) + highscore_suffix + "[br]"
		#for p in time_highscore_particles:
			#p.visible = true
			#p.restart()
			#p.emitting = true
	else:
		text += height_bbcode + Format.get_height_string(height_reached) +  "[br]"
		#for p in time_highscore_particles:
			#p.visible = false
	
	var apples_collected :int = Stats.get_recording_value(Stats.StatType.TOTAL_APPLES_COLLECTED)
	text += apple_bbcode + str( int(apples_collected))
	
	if text.contains("highscore"):
		AudioManager.play_global_sound(new_highscore_sound, -3)
	
	stat_text_node.text = text

func _on_play_again_pressed() -> void:
	GameManager.next_round()


func _on_back_to_menu_pressed() -> void:
	GameManager.quit_to_main()


func _on_back_to_lobby_pressed() -> void:
	GameManager.return_to_lobby()
