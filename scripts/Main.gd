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
#		player_info_ui[i - 1].assigned_player_id = i
		camera.add_target(player)
		i += 1
		
func get_players() -> Array:
	return get_tree().get_nodes_in_group("players")
