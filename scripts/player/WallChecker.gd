extends Node2D

var wall_checkers = []

func _ready():
	for child in get_children():
		if child is RayCast2D:
			wall_checkers.append(child)

func is_colliding() -> bool:
	var result = false
	var colliding_count = 0
	
	if wall_checkers.size() == 0:
		return result
	
	for checker in wall_checkers:
		if checker.is_colliding():
			colliding_count += 1
	
	if colliding_count / wall_checkers.size() > .5:
		result = true
	
	return result
