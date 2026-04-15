extends ShopMenu

@onready var skin_items :Array[Dictionary] = [{
		"name": "Osvald",
		"price": 0,
		"sprite": preload("uid://boqjobpu65xsa")
	},{
		"name": "Castro",
		"price": 1000,
		"sprite": preload("uid://c6vxl4bmc78k2")
	}, {
		"name": "Tiki",
		"price": 1500,
		"sprite": preload("uid://hwtu0ruywc7s")
	},  {
		"name": "Edward",
		"price": 2000,
		"sprite": preload("uid://dyjqt68qoppon")
	}
]

@export var display_rect :TextureRect

func _ready() -> void:
	shop_items = skin_items.duplicate()
	super()

func _refresh_shop_contents() -> void:
	super()
	var item :Dictionary = shop_items[current_shop_index]
	display_rect.texture = item["sprite"]
	var outline_hex :String = DataManager.get_value("selected_outline_hex")
	display_rect.get_material().set_shader_parameter("color", Color(outline_hex))

func _buy(item: Dictionary) -> void:
	super(item)

func _select_item(item_name: String) -> void:
	super(item_name)
	Lobby.transmit_data_to_lobby(Lobby.DataRequestType.COSMETIC_SKIN)
	_refresh_shop_contents()




func _on_outline_pressed() -> void:
	var random_color: Color = Color(randf(),randf(),randf())
	var random_hex :String = "#%s" % random_color.to_html(false)
	DataManager.set_value("selected_outline_hex", random_hex)
	_refresh_shop_contents()
	Lobby.transmit_data_to_lobby(Lobby.DataRequestType.COSMETIC_OUTLINE)

@onready var color_hex_array :Array[String] = [
	Color.GOLDENROD.to_html(false),
	Color.AQUA.to_html(false),
	Color.DARK_MAGENTA.to_html(false),
]

func _get_color_index_from_hex(hex: String) -> int:
	for i in range(color_hex_array.size()):
		if color_hex_array.get(i) == hex:
			return i
	return 0

func _on_prev_color_pressed() -> void:
	pass # Replace with function body.


func _on_random_color_pressed() -> void:
	var prev_color_index :int = _get_color_index_from_hex(DataManager.get_value("selected_outline_hex"))
	var r :int = prev_color_index
	while r == prev_color_index:
		r = randi_range(0, color_hex_array.size() - 1)
	
	_select_color(r)


func _on_next_color_pressed() -> void:
	pass # Replace with function body.

func _select_color(index: int) -> void:
	var hex :String = color_hex_array.get(index)
	if not hex:
		hex = color_hex_array.get(0)
	DataManager.set_value("selected_outline_hex", hex)
	_refresh_shop_contents()
	Lobby.transmit_data_to_lobby(Lobby.DataRequestType.COSMETIC_OUTLINE)
	return
