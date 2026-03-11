extends Control

@onready var animation_player: AnimationPlayer = $animated_frame/AnimationPlayer
@onready var title_label: Label = $animated_frame/title_label
@onready var description_label: Label = $animated_frame/description_label
@onready var background_panel: Panel = $animated_frame/color_background


var alert :Alert = Alert.new()

var seconds_existed :float = 0.0

func _ready() -> void:
	animation_player.play("Alerts/Appear")
	title_label.text = alert.title
	description_label.text = alert.description
	title_label.modulate = alert.COLORS.get(alert.type)

func _process(delta: float) -> void:
	seconds_existed += delta
	
	if seconds_existed >= alert.seconds_active:
		animation_player.play("Alerts/Dissappear")

func kill_alert() -> void:
	animation_player.play("Alerts/Dissappear")
