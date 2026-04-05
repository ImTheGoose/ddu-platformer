extends Node

func _ready() -> void:
	MenuHandler.hide_game()
	if not DataManager.get_value("changelog_seen"):
		MenuHandler.change_menu("changelog")
	else:
		MenuHandler.change_menu("main_menu")

	if OS.has_feature("editor"):
		var args :PackedStringArray= OS.get_cmdline_args()
		var session_num :String = "0"
		for i in range(args.size()):
			if args[i] == "--session":
				session_num = args[i + 1]
				
				
		await get_tree().create_timer(0.2).timeout
		
		DisplayServer.window_set_title("Session : %s" % session_num)
	
	
