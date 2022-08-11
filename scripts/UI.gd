extends CanvasLayer

onready var player_info_panels = [ \
$UI/HBoxContainer/PlayerInfo1, \
$UI/HBoxContainer/PlayerInfo2, \
$UI/HBoxContainer/PlayerInfo3, \
$UI/HBoxContainer/PlayerInfo4]

func _ready():
	Events.connect("player_id_assigned", self, "on_Player_id_assigned")


func on_Player_id_assigned(player):
	for panel in player_info_panels:
		if panel.assigned_player == null:
			panel.assigned_player = player
			break
