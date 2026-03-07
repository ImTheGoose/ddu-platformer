extends Control

class_name GameMenu 

@export var menu_name :String
@export var require_seperator :bool = false
@export var initial_focus :Control
@export var back_button :Button

func _ready() -> void:
	MenuHandler.changed_menu_visibillity.connect(_on_visibillity_changed)
	MenuHandler.register_menu_name(menu_name)
	MenuHandler.request_back_from_menu.connect(_on_request_back_from_menu)
	
	if !initial_focus:
		print("Missing initial focus on " + menu_name)

func _on_request_back_from_menu() -> void:
	if !visible:
		return
	
	if back_button:
		back_button.pressed.emit()

func _on_visibillity_changed(target : String, isVisible : bool) -> void:
	if target == menu_name:
		visible = isVisible
		
		if isVisible:
			_on_show()
			if initial_focus:
				initial_focus.grab_focus()
			
			if require_seperator:
				MenuHandler.show_background_seperator()
		else:
			_on_hide()
			if require_seperator:
					MenuHandler.hide_background_seperator()
		

func _on_show() -> void:
	pass

func _on_hide() -> void:
	pass
