extends GameMenu

@export var BBCode_Icon :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]"
@export var skins :Array[Dictionary] = [{
		"name": "Osvald",
		"price": 0,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Ninja Frog/Jump (32x32).png")
	}, {
		"name": "Tiki",
		"price": 250,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Mask Dude/Jump (32x32).png")
	}, {
		"name": "Castro",
		"price": 500,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Pink Man/Jump (32x32).png")
	}, {
		"name": "Edward",
		"price": 1000,
		"sprite": preload("res://assets/pixel_adventure_assets/Main Characters/Virtual Guy/Jump (32x32).png")
	}
]

var current_shop_index :int = 0
@onready var price_tag = $VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/price_tag
@onready var display_rect = $VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/display_rect
@onready var buy_button = $VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/buy_button
@onready var name_tag = $VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/skin_name_tag
func _ready() -> void:
	super()
	_refresh_shop_contents()

func _show(target):
	super(target)
	if target == menu_name:
		_refresh_shop_contents()
	

func _on_back_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("main_menu")
	pass # Replace with function body.

func _refresh_shop_contents():
	var skin = skins[current_shop_index]
	display_rect.texture = skin["sprite"]
	name_tag.text = skin["name"]

	var owned_skins = DataManager.get_value("owned_skins")
	
	if owned_skins[skin["name"]]:
		buy_button.text = "Select"
		price_tag.text = BBCode_Icon + "Owned"
		
		if DataManager.get_value("selected_skin") == skin["name"]:
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
	
	if DataManager.get_value("owned_skins")[skin["name"]]:
		_select_skin(skin["name"])
	else:
		_buy_skin(skin)
		
	_refresh_shop_contents()

func _buy_skin(skin):
	var money = DataManager.get_value("money")
	var price = float(skin["price"])
	
	if money < price:
		return
	
	money -= price
	DataManager.set_value("money", money)	
	
	var owned_skins = DataManager.get_value("owned_skins")
	owned_skins[skin["name"]] = true
	DataManager.set_value("owned_skins", owned_skins)	
	
	


func _select_skin(skin_name: String):
	DataManager.set_value("selected_skin", skin_name)
	
