extends ShopMenu

@onready var theme_items :Array[Dictionary] = [{
		"name": "Default",
		"price": 0,
		"texture": preload("res://assets/pixel_adventure_assets/Terrain/Terrain_Default.png")
	},{
		"name": "Candy",
		"price": 500,
		"texture": preload("res://assets/pixel_adventure_assets/Terrain/Terrain_Candy.png")
	},{
		"name": "Hell",
		"price": 750,
		"texture": preload("res://assets/pixel_adventure_assets/Terrain/Terrain_Hell.png")
	},{
		"name": "Castle",
		"price": 750,
		"texture": preload("res://assets/pixel_adventure_assets/Terrain/Terrain_Castle.png")
	},{
		"name": "Abyss",
		"price": 1000,
		"texture": preload("res://assets/pixel_adventure_assets/Terrain/Terrain_Abyss.png")
	},{
		"name": "Icey",
		"price": 1000,
		"texture": preload("res://assets/pixel_adventure_assets/Terrain/Terrain_Icey.png")
	},
]

@export var display_tilemap :TileMapLayer

func _hide() -> void:
	super()
	if shop_items.size() == 0:
		return
	var selected_item_name :String = DataManager.get_value("selected_" + shop_category)
	for item in shop_items:
		if item["name"] == selected_item_name:
			var selected_item :Dictionary = item
			display_tilemap.tile_set.get_source(0).texture = selected_item["texture"]


func _ready() -> void:
	shop_items = theme_items.duplicate()
	super()

func _refresh_shop_contents() -> void:
	super()
	var item :Dictionary = shop_items[current_shop_index]
	display_tilemap.tile_set.get_source(0).texture = item["texture"]
	
