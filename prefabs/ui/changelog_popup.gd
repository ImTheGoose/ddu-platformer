extends GameMenu

@export var title :String = "Update x.x!"

@export_category("Added Content")
@export var added_bbcode :String = ""
@export var added_list :Array[String] = [""]

@export_category("Changed Content")
@export var changed_bbcode :String = ""
@export var changed_list :Array[String] = [""]

@export_category("Removed Content")
@export var removed_bbcode :String = ""
@export var removed_list :Array[String] = [""]

@onready var title_node :Label = $PanelContainer/VBoxContainer/ScrollContainer/ContentList/Changelog_Titel
@onready var description_rich_node :RichTextLabel = $PanelContainer/VBoxContainer/ScrollContainer/ContentList/Changelog_Description

func _ready() -> void:
	super()
	title_node.text = title
	
	var desc := ""
	for ai in added_list:
		desc += added_bbcode + ai + "[br]"
	
	for ci in changed_list:
		desc += changed_bbcode + ci + "[br]"
	
	for ri in removed_list:
		desc += removed_bbcode + ri + "[br]"
	
	description_rich_node.text = desc



func _on_close_pressed() -> void:
	MenuManager.hide_all_menus.emit()
	MenuManager.show_menu.emit("main_menu")
	DataManager.set_value("changelog_seen", true)
	pass # Replace with function body.
