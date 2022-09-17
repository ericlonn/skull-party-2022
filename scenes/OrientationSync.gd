extends Node

onready var player = owner as Player
onready var parent = get_parent()

var current_orientation = 1

func _ready():
	yield(player, "ready")
	player.orientation.connect("orientation_updated", self, "orientation_updated")

func orientation_updated(orientation: int):
	if orientation == 0:
		return
		
	if current_orientation == orientation:
		return
	
	parent.position.x = parent.position.x * -1
	parent.scale.x = parent.scale.x * -1
	
	current_orientation = sign(orientation)
