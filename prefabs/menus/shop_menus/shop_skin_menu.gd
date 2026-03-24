extends ShopMenu

@onready var outline_button:Button = %outline_button
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
	outline_button.pressed.connect(_on_outline_pressed)

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
