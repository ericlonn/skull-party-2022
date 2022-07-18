extends HBoxContainer

var assigned_player_id setget set_assigned_player_id

onready var skull1: TextureRect = $Skull1
onready var skull2: TextureRect = $Skull2
onready var skull3: TextureRect = $Skull3

onready var ui_skulls = [skull1, skull2, skull3]

func _init():
	visible = false

func set_assigned_player_id(value):
	if value is int and value >= 1 and value <= 4:
		assigned_player_id = value
		visible = true
	else:
		visible = false

func _on_Player_powerskull_count_updated(player, skulls):
	print(skulls as String)
	var i = 0
	for ui_skull in ui_skulls:
		if i < skulls.size():
			match skulls[i]:
				0:
					ui_skull.modulate = Color.red
				1:
					ui_skull.modulate = Color.green
				2:
					ui_skull.modulate = Color.blue
		else:
			ui_skull.modulate = Color.gray
		i += 1
