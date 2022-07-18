extends Node2D

onready var squash_stretch: Tween = $SquashStretch

export(float, 0.0, 1.0) var squash_amount = .4
export var squash_speed = 0.2
export(float, 0.0, 1.0) var stretch_amount = .4
export var stretch_speed = 0.2

func squash():
	var squash_vector = Vector2(1.0 + squash_amount, 1.0 - squash_amount)
	squash_stretch.remove_all()
	scale = Vector2.ONE
	squash_stretch.interpolate_property(self, "scale", squash_vector, Vector2.ONE, squash_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	squash_stretch.start()

func stretch():
	var stretch_vector = Vector2(1.0 - stretch_amount, 1.0 + stretch_amount)
	squash_stretch.remove_all()
	scale = Vector2.ONE
	squash_stretch.interpolate_property(self, "scale", stretch_vector, Vector2.ONE, stretch_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	squash_stretch.start()
