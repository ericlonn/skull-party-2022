extends RigidBody2D
class_name Ammo_rigid

var firing_direction: int = 1 setget set_firing_direction
var color
var player


func set_firing_direction(value):
	if value == 0:
		value = 1
		return
	
	value = sign(value)
