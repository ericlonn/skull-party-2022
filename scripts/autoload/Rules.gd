tool
extends Node

enum powerskull_types {RED, GREEN, BLUE}

func get_skull_color(skull_type: int = -1) -> Color:
	if skull_type < 0 or skull_type > powerskull_types.size() - 1:
		return Color(0,0,0,1)
	
	match skull_type:
		0:
			return Color.lightcoral
		1:
			return Color.lightgreen
		2:
			return Color.lightblue
		
	return Color(0,0,0,1)
