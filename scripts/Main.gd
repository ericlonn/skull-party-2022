extends Node2D

onready var camera = $Camera2D

onready var player1_info_ui = $CanvasLayer/UI/HBoxContainer/Player1Info
onready var player2_info_ui = $CanvasLayer/UI/HBoxContainer/Player2Info
onready var player3_info_ui = $CanvasLayer/UI/HBoxContainer/Player3Info
onready var player4_info_ui = $CanvasLayer/UI/HBoxContainer/Player4Info
onready var player_info_ui = [player1_info_ui, player2_info_ui, player3_info_ui, player4_info_ui]

onready var skull_spawner = $SkullSpawner

func _ready():
	var players = get_tree().get_nodes_in_group("players")
	
	var i: int = 1
	for player in players:
		player.id = i
		player_info_ui[i - 1].assigned_player_id = i
		player.connect("powerskulls_updated", player_info_ui[i - 1], "_on_Player_powerskull_count_updated")
		player.connect("powerskull_lost", skull_spawner, "_on_Player_skull_lost")
		camera.add_target(player)
		i += 1
