extends GameMenu

class_name ShopMenu

@export var price_BBCode_Icon :String = "[img]res://assets/pixel_adventure_assets/Items/Fruits/Apple_16x16.png[/img]"
@export var shop_category :String = ""

var shop_items :Array[Dictionary] = [{}]
var current_shop_index :int = 0

@export var price_tag :RichTextLabel
@export var buy_button :Button
@export var name_tag :RichTextLabel

func _ready() -> void:
	super()
	_refresh_shop_contents()

func _on_show() -> void:
		_refresh_shop_contents()

func _on_back_pressed() -> void:
	MenuHandler.change_menu("shop_selection_menu")

func _refresh_shop_contents() -> void:
	var item :Dictionary = shop_items[current_shop_index]
	name_tag.text = item["name"]
	price_tag.text = price_BBCode_Icon + str( int( item["price"]))

	var owned_category_items :Variant = DataManager.get_value("owned_" + shop_category)

	if owned_category_items[item["name"]]:
		buy_button.text = "Select"
		price_tag.text = price_BBCode_Icon + "Owned"

		if DataManager.get_value("selected_" + shop_category) == item["name"]:
			buy_button.text = "Selected"

	else:
		buy_button.text = "Buy"
		price_tag.text = price_BBCode_Icon + str( int( item["price"]))

func _on_next_pressed() -> void:
	current_shop_index += 1

	if current_shop_index >= shop_items.size():
		current_shop_index = 0
	
	_refresh_shop_contents()


func _on_previous_pressed() -> void:
	current_shop_index -= 1

	if current_shop_index < 0:
		current_shop_index = shop_items.size() - 1
		
	_refresh_shop_contents()

func _on_buy_button_pressed() -> void:
	var item :Dictionary = shop_items[current_shop_index]

	if DataManager.get_value("owned_" + shop_category)[item["name"]]:
		_select_item(item["name"])
	else:
		_buy(item)
	
	_refresh_shop_contents()

func _select_item(item_name: String) -> void:
	DataManager.set_value("selected_" + shop_category, item_name)

func _buy(item: Dictionary) -> void:
	var money :float = DataManager.get_value("money")
	var price :float = float(item["price"])

	if money < price:
		return
	
	money -= price
	DataManager.set_value("money", money)

	var owned_contents :Variant = DataManager.get_value("owned_" + shop_category)
	owned_contents[item["name"]] = true
	DataManager.set_value("owned_" + shop_category, owned_contents)
	DataManager.save_game_data()
