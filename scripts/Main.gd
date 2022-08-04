extends Node2D

onready var camera = $Camera2D

onready var player1_info_ui = $UI/UI/HBoxContainer/Player1Info
onready var player2_info_ui = $UI/UI/HBoxContainer/Player2Info
onready var player3_info_ui = $UI/UI/HBoxContainer/Player3Info
onready var player4_info_ui = $UI/UI/HBoxContainer/Player4Info
onready var player_info_ui = [player1_info_ui, player2_info_ui, player3_info_ui, player4_info_ui]

func _ready():
	add_snes_controller_mapping()
	
	var players = get_tree().get_nodes_in_group("players")
	
	var i: int = 1
	for player in players:
		player.id = i
#		player_info_ui[i - 1].assigned_player_id = i
		camera.add_target(player)
		i += 1
		
func get_players() -> Array:
	return get_tree().get_nodes_in_group("players")


func add_snes_controller_mapping():
	Input.add_joy_mapping("03000000790000001100000000000000,Retro Controller,a:b2,b:b1,y:b0,x:b3,start:b9,back:b8,leftshoulder:b4,rightshoulder:b5,dpup:-a4,dpleft:-a3,dpdown:+a4,dpright:+a3,platform:Windows", true)
