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

@onready var title_node :Label = %Changelog_Titel
@onready var description_rich_node :RichTextLabel = %Changelog_Description

func _ready() -> void:
	super()
	title_node.text = title
	
	var desc := ""
	for a in added_list:
		desc += added_bbcode + a + "[br]"
	
	for c in changed_list:
		desc += changed_bbcode + c + "[br]"
	
	for r in removed_list:
		desc += removed_bbcode + r + "[br]"
	
	description_rich_node.text = desc


func _on_close_pressed() -> void:
	MenuHandler.change_menu("main_menu")
	DataManager.set_value("changelog_seen", true)
