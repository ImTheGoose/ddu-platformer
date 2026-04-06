extends ShopMenu

@onready var accent_items :Array[Dictionary] = [{
		"name": "Brown",
		"price": 0,
		"texture": preload("uid://djvdn4edth2po")
	},{
		"name": "Red",
		"price": 250,
		"texture": preload("uid://cyo6dhvlxakth")
	},{
		"name": "Gray",
		"price": 250,
		"texture": preload("uid://ob77turt7mcj")
	},{
		"name": "Pink",
		"price": 250,
		"texture": preload("uid://bxwx3outaa45n")
	},{
		"name": "Blue",
		"price": 500,
		"texture": preload("uid://hp36vp4rgh30")
	},{
		"name": "Green",
		"price": 500,
		"texture": preload("uid://cfyrwu5jj40ea")
	},{
		"name": "Black",
		"price": 500,
		"texture": preload("uid://cjnmrel60l871")
	},
]

@export var display_rect :TextureRect

func _ready() -> void:
	shop_items = accent_items.duplicate()
	super()

func _refresh_shop_contents() -> void:
	super()
	var item :Dictionary = shop_items[current_shop_index]
	display_rect.texture = item["texture"]
