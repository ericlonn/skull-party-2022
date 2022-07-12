extends Node2D

onready var camera = $Camera2D

func _ready():
	var players = get_tree().get_nodes_in_group("players")
	
	for player in players:
		camera.add_target(player)
