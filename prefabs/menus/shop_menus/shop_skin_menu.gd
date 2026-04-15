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

@onready var color_hex_array :Array[String] = [
	Color.WHITE.to_html(false),
	Color.LIGHT_CORAL.to_html(false),        # 1. Soft Red
	Color.SALMON.to_html(false),             # 2. Red-Orange
	Color.CORAL.to_html(false),              # 3. Orange
	Color.SANDY_BROWN.to_html(false),        # 4. Golden-Orange
	Color.GOLDENROD.to_html(false),          # 5. Warm Yellow
	Color.PALE_GOLDENROD.to_html(false),     # 6. Soft Yellow
	Color.GREEN_YELLOW.to_html(false),       # 7. Chartreuse
	Color.LIGHT_GREEN.to_html(false),        # 8. Bright Green
	Color.MEDIUM_SPRING_GREEN.to_html(false),# 9. Spring Green
	Color.MEDIUM_AQUAMARINE.to_html(false),  # 10. Mint/Teal
	Color.MEDIUM_TURQUOISE.to_html(false),   # 11. Cyan/Aqua
	Color.SKY_BLUE.to_html(false),           # 12. Light Blue
	Color.CORNFLOWER_BLUE.to_html(false),    # 13. Periwinkle Blue
	Color.MEDIUM_SLATE_BLUE.to_html(false),  # 14. Indigo-ish
	Color.MEDIUM_PURPLE.to_html(false),      # 15. Violet
	Color.ORCHID.to_html(false),             # 16. Magenta/Purple
	Color.HOT_PINK.to_html(false),           # 17. Pink
	Color.LIGHT_PINK.to_html(false)          # 18. Rose/Red-Pink
]

func _get_color_index_from_hex(hex: String) -> int:
	for i in range(color_hex_array.size()):
		if color_hex_array.get(i) == hex:
			return i
	return 0

func _on_prev_color_pressed() -> void:
	var prev_color_index :int = _get_color_index_from_hex(DataManager.get_value("selected_outline_hex"))
	match prev_color_index:
		0:
			_select_color(color_hex_array.size() - 1)
		_:
			_select_color(prev_color_index - 1)


func _on_random_color_pressed() -> void:
	var prev_color_index :int = _get_color_index_from_hex(DataManager.get_value("selected_outline_hex"))
	var r :int = prev_color_index
	while r == prev_color_index:
		r = randi_range(0, color_hex_array.size() - 1)
	
	_select_color(r)


func _on_next_color_pressed() -> void:
	var prev_color_index :int = _get_color_index_from_hex(DataManager.get_value("selected_outline_hex"))
	var max_index :int = color_hex_array.size() - 1
	match prev_color_index:
		max_index:
			_select_color(0)
		_:
			_select_color(prev_color_index + 1)

func _select_color(index: int) -> void:
	var hex :String = color_hex_array.get(index)
	if not hex:
		hex = color_hex_array.get(0)
	DataManager.set_value("selected_outline_hex", hex)
	_refresh_shop_contents()
	Lobby.transmit_data_to_lobby(Lobby.DataRequestType.COSMETIC_OUTLINE)
	return
