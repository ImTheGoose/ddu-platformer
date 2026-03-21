extends HBoxContainer

@onready var placement_label: Label = %placement_label
@onready var avatar_rect: TextureRect = %avatar_rect
@onready var player_name_label: Label = %player_name_label
@onready var player_score_label: Label = %player_score_label

signal labels_changed()
var assigned_peer_id :int = -1
var assigned_player_info :PlayerInfo

func _ready() -> void:
	if assigned_peer_id == -1:
		return
	
	GameManager.game_scores_changed.connect(_on_scores_changed)
	
	assigned_player_info = Lobby.get_player_info(assigned_peer_id)
	avatar_rect.texture = assigned_player_info.get_avatar_texture(128)
	refresh_labels()

func _on_scores_changed() -> void:
	refresh_labels()

func refresh_labels() -> void:
	player_name_label.text = assigned_player_info.DISPLAY_NAME
	player_score_label.text = "Time alive - %s" % TimeFormat.get_time_string(GameManager.get_score(assigned_peer_id), 0.01)
	var placement:int = GameManager.get_placement(assigned_peer_id)
	match placement:
		1:
			placement_label.text = "%sst" % placement
			set_label_colors(Color.GOLDENROD)
		2:
			placement_label.text = "%snd" % placement
			set_label_colors(Color.SILVER)
		3:
			placement_label.text = "%srd" % placement
			set_label_colors(Color.CHOCOLATE)
		_:
			placement_label.text = "%sth" % placement
			set_label_colors(Color(0.25, 0.25, 0.25, 1.0))
	labels_changed.emit()

func set_label_colors(color: Color) -> void:
	placement_label.add_theme_color_override("font_color", color)
	player_name_label.add_theme_color_override("font_color", color)
	player_score_label.add_theme_color_override("font_color", color)
