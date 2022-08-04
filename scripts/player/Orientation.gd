extends Node2D

signal orientation_updated

onready var squash_stretch: Tween = $SquashStretch

export(float, 0.0, 1.0) var squash_amount = .4
export var squash_speed = 0.2
export(float, 0.0, 1.0) var stretch_amount = .4
export var stretch_speed = 0.2

func squash():
	squash_stretch.remove_all()
		
	var squash_vector = Vector2(1.0 + squash_amount, 1.0 - squash_amount)
	squash_vector.x *= sign(scale.x)

	scale.y = 1
	scale.x = 1 * sign(scale.x)
	
	var goal_vector = Vector2(1 * sign(scale.x), 1)
	
	squash_stretch.interpolate_property(self, "scale", squash_vector, goal_vector, squash_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	squash_stretch.start()

func stretch():
	squash_stretch.remove_all()
	
	var stretch_vector = Vector2(1.0 - stretch_amount, 1.0 + stretch_amount)
	stretch_vector.x *= sign(scale.x)
	
	scale.y = 1
	scale.x = 1 * sign(scale.x)
	
	var goal_vector = Vector2(1 * sign(scale.x), 1)
	
	squash_stretch.interpolate_property(self, "scale", stretch_vector, goal_vector, stretch_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	squash_stretch.start()

func face_left():
	if sign(scale.x) == 1:
		emit_signal("orientation_updated", -1)
	
	if sign(scale.x) == 1 and squash_stretch.is_active():
		squash_stretch.remove_all()
	scale.x = -1
	scale.y = 1
	
	
func face_right():
	if sign(scale.x) == -1:
		emit_signal("orientation_updated", 1)
	
	if sign(scale.x) == -1 and squash_stretch.is_active():
		squash_stretch.remove_all()
	scale.x = 1
	scale.y = 1


func flip_around():
	if squash_stretch.is_active():
		squash_stretch.remove_all()
	scale.x = -sign(scale.x)
	scale.y = 1
	
	emit_signal("orientation_updated", scale.x)
