extends GameMenu

@export var time_bbcode :String = "[img]res://assets/icons/time (16x16).png[/img]Time alive - "
@export var apple_bbcode :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]Apples collected - "
@export var highscore_text :String = " (new highscore)"

var new_highscore_sound :AudioStreamMP3 = AudioStreamMP3.load_from_file("res://assets/audio/sfx/new_highscore.mp3")
@onready var stat_text_node :RichTextLabel = $stat_text
@onready var apple_highscore_particle1 :GPUParticles2D = $apple_highscore_particles
@onready var apple_highscore_particle2 :GPUParticles2D = $apple_highscore_particles2
@onready var time_highscore_particle1 :GPUParticles2D = $time_highscore_particles
@onready var time_highscore_particle2 :GPUParticles2D = $time_highscore_particles2

func _hide() -> void:
	super()
	MenuManager.toggle_background_seperator.emit(false)

func _show(target: String) -> void:
	super(target)
	if target == menu_name:
		MenuManager.toggle_background_seperator.emit(true)
		_refresh_stat_text()


func _refresh_stat_text() -> void:
	var text :String = ""
	var time_alive :Variant = StatisticManager.get_value("time_alive")
	if time_alive >= DataManager.get_value("statistics")["time_highscore"]:
		text += time_bbcode + TimeFormat.get_time_string(time_alive) + highscore_text + "[br]"
		time_highscore_particle1.visible = true
		time_highscore_particle2.visible = true
		time_highscore_particle1.restart()
		time_highscore_particle2.restart()
		time_highscore_particle1.emitting = true
		time_highscore_particle2.emitting = true
	else:
		text += time_bbcode + TimeFormat.get_time_string(time_alive) +  "[br]"
		time_highscore_particle1.visible = false
		time_highscore_particle2.visible = false
	
	var apples_collected :int = StatisticManager.get_value("apples_collected")
	
	if apples_collected >= DataManager.get_value("statistics")["apple_highscore"]:
		text += apple_bbcode + str( int(apples_collected)) + highscore_text
		apple_highscore_particle1.visible = true
		apple_highscore_particle2.visible = true
		apple_highscore_particle1.restart()
		apple_highscore_particle2.restart()
		apple_highscore_particle1.emitting = true
		apple_highscore_particle2.emitting = true
	else:
		apple_highscore_particle1.visible = false
		apple_highscore_particle2.visible = false
		text += apple_bbcode + str( int(apples_collected))
	
	if text.contains("highscore"):
		AudioManager.play_global_sound(new_highscore_sound, -3)
	
	stat_text_node.text = text

func _on_play_again_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	GameManager.reset_game()
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.toggle_game_visibillity.emit(false)
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.
