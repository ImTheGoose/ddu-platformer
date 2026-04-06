extends ShopMenu

@onready var theme_items :Array[Dictionary] = [{
		"name": "Default",
		"price": 0,
		"texture": preload("uid://dn7a53xq84u84")
	},{
		"name": "Candy",
		"price": 500,
		"texture": preload("uid://i34411mdywpl")
	},{
		"name": "Hell",
		"price": 750,
		"texture": preload("uid://cyhcx4oa7q2v7")
	},{
		"name": "Castle",
		"price": 750,
		"texture": preload("uid://dm3sasdp6uenx")
	},{
		"name": "Abyss",
		"price": 1000,
		"texture": preload("uid://vc56e8nljq03")
	},{
		"name": "Icey",
		"price": 1000,
		"texture": preload("uid://85kx44r5tjpi")
	},
]

@export var display_tilemap :TileMapLayer

func _on_hide() -> void:
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
	
