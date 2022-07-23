extends Panel

var assigned_player_id setget set_assigned_player_id

func _ready():
	visible = false
	Events.connect("skull_count_updated", self, "_on_Player_skull_count_updated")

func set_skull_count():
	pass

func set_assigned_player_id(value):
	assigned_player_id = value
	var player_color = Rules.get_player_color(assigned_player_id)
	get_stylebox("panel", "").border_color = player_color
	
	visible = true
