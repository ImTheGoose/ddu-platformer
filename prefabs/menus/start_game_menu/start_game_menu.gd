extends GameMenu

@onready var difficulty_dropdown :OptionButton = %difficulty_dropdown
@onready var diffculty_stat_label :RichTextLabel = %difficulty_stats
@onready var map_collection_dropdown: OptionButton = %map_collection_dropdown
@export var collectable_bbcode :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]"
@export var enemy_bbcode :String = "[img]res://assets/icons/Mushroom (16x16).png[/img]"
@export var speed_bbcode :String = "[img]res://assets/pixel_adventure_assets/Other/dust (16x16).png[/img]"

@onready var time_highscore_label: RichTextLabel = %time_highscore_label
var time_original_string: String = ""
@onready var apple_highscore_label: RichTextLabel = %apple_highscore_label
var apple_original_string: String = ""
const highscore_embedded_string :String = ""

func _ready() -> void:
	super()
	time_original_string = time_highscore_label.text
	apple_original_string = apple_highscore_label.text
	var dif :Difficulty.Type = Difficulty.get_difficulty()
	difficulty_dropdown.selected = difficulty_dropdown.get_item_index(dif)
	_refresh_stats()
	_initialise_collection_dropdown()

func _on_show() -> void:
	difficulty_dropdown.select(Difficulty.get_difficulty())
	map_collection_dropdown.select(map_collection_dropdown.get_item_index(GameManager.get_map_collection()))
	_refresh_stats()

func _initialise_collection_dropdown() -> void:
	map_collection_dropdown.clear()
	for collection:String in MapFile.CollectionType.keys():
		if not OS.is_debug_build():
			if not MapFile.VISIBLE_COLLECTIONS_IN_RELEASE.has(MapFile.CollectionType[collection]):
				continue
		
		map_collection_dropdown.add_item(collection.capitalize(), MapFile.CollectionType[collection])
	
	map_collection_dropdown.select(map_collection_dropdown.get_item_index(GameManager.get_map_collection()))

func _refresh_stats() -> void:
	var time_highscore :float = Stats.get_float_stat(Stats.get_time_highscore_type())
	time_highscore_label.text = time_original_string % [Difficulty.get_difficulty() + 1, Format.get_time_string(time_highscore)]
	
	var apple_highscore :float = Stats.get_int_stat(Stats.get_apple_highscore_type())
	apple_highscore_label.text = apple_original_string % [Difficulty.get_difficulty() + 1, Format.get_time_string(apple_highscore)]
	
	time_highscore_label.bbcode_enabled = true
	apple_highscore_label.bbcode_enabled = true
	
	var tex :String = enemy_bbcode
	
	tex += str( int(Difficulty.get_setting(Difficulty.Settings.ENEMY_SPAWN_RATE) * 100)) + "%[br]"
	tex += collectable_bbcode
	tex += str( int(Difficulty.get_setting(Difficulty.Settings.COLLECTABLE_SPAWN_RATE) * 100)) + "%[br]"
	tex += speed_bbcode
	tex += str( int(Difficulty.get_setting(Difficulty.Settings.CAMERA_SPEED_SCALE) * 100)) + "%"
	diffculty_stat_label.text = tex

func _on_start_game_pressed() -> void:
	GameManager.prepare_game()


func _on_back_pressed() -> void:
	MenuHandler.change_menu("select_play_menu")


func _on_difficulty_dropdown_item_selected(index: int) -> void:
	Difficulty.set_difficulty(index)
	_refresh_stats()


func _on_map_collection_dropdown_item_selected(index: int) -> void:
	var id :int = map_collection_dropdown.get_item_id(index)
	GameManager.set_map_collection(id)
	pass # Replace with function body.
