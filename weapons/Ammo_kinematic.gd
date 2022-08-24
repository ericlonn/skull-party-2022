extends KinematicBody2D
class_name Ammo_kinematic

var firing_direction: int = 1 setget set_firing_direction
var color
var player


func set_firing_direction(value):
	if value == 0:
		firing_direction = 1
		return
	
	firing_direction = sign(value)
