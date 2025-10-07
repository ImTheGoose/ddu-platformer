extends ShopMenu

@onready var skin_items :Array[Dictionary] = [{
		"name": "Osvald",
		"price": 0,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Ninja Frog/Jump (32x32).png")
	},{
		"name": "Castro",
		"price": 1000,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Pink Man/Jump (32x32).png")
	}, {
		"name": "Tiki",
		"price": 1500,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Mask Dude/Jump (32x32).png")
	},  {
		"name": "Edward",
		"price": 2000,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Virtual Guy/Jump (32x32).png")
	}
]

@export var display_rect :TextureRect

func _ready() -> void:
	shop_items = skin_items.duplicate()
	super()

func _refresh_shop_contents():
	super()
	var item = shop_items[current_shop_index]
	display_rect.texture = item["sprite"]
