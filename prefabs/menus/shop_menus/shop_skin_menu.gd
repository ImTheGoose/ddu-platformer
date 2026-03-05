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
