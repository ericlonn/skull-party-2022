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
			return Color.cyan
		
	return Color(0,0,0,1)

func get_player_color(player_id: int) -> Color:
	match player_id:
		1:
			return Color.deeppink
		2:
			return Color.coral
		3:
			return Color.deepskyblue
		4:
			return Color.mediumspringgreen
	
	return Color.brown
