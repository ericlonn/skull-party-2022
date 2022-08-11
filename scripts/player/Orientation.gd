extends Node2D

signal orientation_updated

onready var player = owner


func face_left():
	emit_signal("orientation_updated", -1)
	
	scale.x = -1
	scale.y = 1
	
	
func face_right():
	emit_signal("orientation_updated", 1)
	
	scale.x = 1
	scale.y = 1


func flip():
	emit_signal("orientation_updated", scale.x)
	
	scale.x = -sign(scale.x)
	scale.y = 1
	

func orient_character(manual_direction = 0):
	if manual_direction == 0:
		match player.input.move_direction:
			1:
				face_right()
			-1:
				face_left()
	else:
		manual_direction = 1 if manual_direction > 0 else -1
		match manual_direction:
			1:
				face_right()
			-1:
				face_left()
