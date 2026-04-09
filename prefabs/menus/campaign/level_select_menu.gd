extends GameMenu

@export var next_button :Button
@export var previous_button :Button
var level_index_offset :int = 0

@onready var top_half: HBoxContainer = %top_half
@onready var bottom_half: HBoxContainer = %bottom_half
@onready var level_card_prefab: PackedScene = preload("uid://cn1x1bxgo5rj0")

signal index_offset_changed(new_index: int)
signal update_focus

func _ready() -> void:
	super()
	next_button.pressed.connect(_next)
	previous_button.pressed.connect(_previous)
	_instatiate_cards()
	_update_limits()

func _on_show() -> void:
	DataManager.set_value("unlocked_level", randi_range(1, 50))
	_update_limits()
	_force_focus()

func _update_limits() -> void:
	index_offset_changed.emit(level_index_offset)
	#MenuManager.level_index_offset.emit(level_index_offset)
	if level_index_offset <= 0:
		previous_button.disabled = true
		previous_button.self_modulate = Color.TRANSPARENT
		previous_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		previous_button.disabled = false
		previous_button.self_modulate = Color.WHITE
		previous_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
	if level_index_offset >= DataManager.get_value("unlocked_level") - 10:
		next_button.disabled = true
		next_button.self_modulate = Color.TRANSPARENT
		next_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		next_button.disabled = false
		next_button.self_modulate = Color.WHITE
		next_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_force_focus()

func _instatiate_cards() -> void:
	var children :Array[Node] = top_half.get_children()
	children.append_array(bottom_half.get_children())
	for child:Node in children:
		child.queue_free()
	
	for i in range(1, 11):
		var card :LevelButton = level_card_prefab.instantiate()
		card.level_num = i
		card.level_offset = level_index_offset
		index_offset_changed.connect(card._update_level_index)
		update_focus.connect(card._on_foucs)
		if i <= 5:
			top_half.add_child(card)
		else:
			bottom_half.add_child(card)
		
	index_offset_changed.emit(level_index_offset)

func _force_focus() -> void:
	var unl_lvl :int = DataManager.get_value("unlocked_level") 
	if unl_lvl >= level_index_offset:
		if unl_lvl <= level_index_offset + 10:
			update_focus.emit()
		else:
			next_button.grab_focus()
	else:
		previous_button.grab_focus()

func _next() -> void:
	level_index_offset += 10
	_update_limits()

func _previous() -> void:
	level_index_offset -= 10
	_update_limits()

func _on_back_button_pressed() -> void:
	MenuHandler.change_menu("select_play_menu")
