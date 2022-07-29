extends Node2D

var enabled = false setget set_enabled

onready var flames: Particles2D = $PowerUpFlames

func set_enabled(value):
	if value:
		flames.emitting = true
	else:
		flames.emitting = false


func set_color(player_color: Color):
	flames.process_material.color = player_color
