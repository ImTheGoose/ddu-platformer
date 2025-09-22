extends ShopMenu

@onready var accent_items :Array[Dictionary] = [{
		"name": "Brown",
		"price": 0,
		"texture": preload("res://assets/pixel_adventure_assets/Background/Brown.png")
	},{
		"name": "Blue",
		"price": 500,
		"texture": preload("res://assets/pixel_adventure_assets/Background/Blue.png")
	},{
		"name": "Gray",
		"price": 500,
		"texture": preload("res://assets/pixel_adventure_assets/Background/Gray.png")
	},{
		"name": "Green",
		"price": 500,
		"texture": preload("res://assets/pixel_adventure_assets/Background/Green.png")
	},{
		"name": "Pink",
		"price": 500,
		"texture": preload("res://assets/pixel_adventure_assets/Background/Pink.png")
	},{
		"name": "Purple",
		"price": 500,
		"texture": preload("res://assets/pixel_adventure_assets/Background/Purple.png")
	},{
		"name": "Yellow",
		"price": 500,
		"texture": preload("res://assets/pixel_adventure_assets/Background/Yellow.png")
	},
]

@export var display_rect :TextureRect

func _ready() -> void:
	shop_items = accent_items.duplicate()
	super()

func _refresh_shop_contents():
	super()
	var item = shop_items[current_shop_index]
	display_rect.texture = item["texture"]
