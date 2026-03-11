extends Node

signal new_alert(alert : Alert)

func push_error(title: String, description: String):
	var alert := create_alert(title, description)
	alert.type = Alert.Types.error
	push_alert(alert)

func push_warning(title: String, description: String):
	var alert := create_alert(title, description)
	alert.type = Alert.Types.warning
	push_alert(alert)

func push_success(title: String, description: String):
	var alert := create_alert(title, description)
	alert.type = Alert.Types.success
	push_alert(alert)

func push_default(title: String, description: String):
	var alert := create_alert(title, description)
	push_alert(alert)

func create_alert(title : String = "", description: String = "") -> Alert:
	var alert := Alert.new()
	alert.title = title
	alert.description = description
	return alert

func push_alert(alert : Alert):
	new_alert.emit(alert)
