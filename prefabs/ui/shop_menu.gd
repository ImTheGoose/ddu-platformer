extends GameMenu

@export var BBCode_Icon :String = "[img]res://asset_pack/Items/Fruits/Apple_16x16.png[/img]"
@export var skins :Array[Dictionary] = [{
		"name": "Ninja Frog",
		"price": 0,
		"sprite": preload("res://asset_pack/Main Characters/Ninja Frog/Jump (32x32).png")
	}, {
		"name": "Pink Man",
		"price": 2500,
		"sprite": preload("res://asset_pack/Main Characters/Pink Man/Jump (32x32).png")
	}, {
		"name": "Virtual Guy",
		"price": 5000,
		"sprite": preload("res://asset_pack/Main Characters/Virtual Guy/Jump (32x32).png")
	}, {
		"name": "Mask Dude",
		"price": 10000,
		"sprite": preload("res://asset_pack/Main Characters/Mask Dude/Jump (32x32).png")
	}
]

var owned_skins = {
	"Ninja Frog": true,
	"Pink Man": false,
	"Virtual Guy": false,
	"Mask Dude": false
}

var selected_skin_name :String = "Ninja Frog"
var current_shop_index :int = 0
@onready var price_tag = $MarginContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/price_tag
@onready var display_rect = $MarginContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/display_rect
@onready var buy_button = $MarginContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/buy_button


func _ready() -> void:
	super()
	_refresh_shop_contents()

func _on_back_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.

func _refresh_shop_contents():
	var skin = skins[current_shop_index]
	display_rect.texture = skin["sprite"]

	if owned_skins[skin["name"]]:
		buy_button.text = "Select"
		price_tag.text = "Owned"
		
		if selected_skin_name == skin["name"]:
			buy_button.text = "Selected"
		return

	buy_button.text = "Buy"
	price_tag.text = BBCode_Icon + str(skin["price"])


func _on_next_pressed() -> void:
	current_shop_index += 1
	
	if current_shop_index >= skins.size():
		current_shop_index = 0
	
	_refresh_shop_contents()


func _on_previous_pressed() -> void:
	current_shop_index -= 1
	
	if current_shop_index < 0:
		current_shop_index = skins.size() - 1
		
	_refresh_shop_contents()


func _on_buy_button_pressed() -> void:
	var skin = skins[current_shop_index]
	
	if owned_skins[skin["name"]]:
		_select_skin(skin["name"])
	else:
		_buy_skin(skin["name"])
		
	_refresh_shop_contents()

func _buy_skin(skin_name: String):
	owned_skins[skin_name] = true

func _select_skin(skin_name: String):
	selected_skin_name = skin_name
	
