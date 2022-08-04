extends Node

onready var parent = get_parent()

var current_orientation = 1

func _on_Orientation_orientation_updated(orientation: int):
	if orientation == 0:
		return
		
	if current_orientation == orientation:
		return
	
	parent.position.x = parent.position.x * -1
	parent.scale.x = parent.scale.x * -1
	
	current_orientation = sign(orientation)
