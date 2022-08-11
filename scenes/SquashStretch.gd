extends Tween

onready var parent = get_parent()
onready var resting_scale = parent.scale

export(float, 0.0, 1.0) var squash_amount = .1
export var squash_speed = 0.2
export(float, 0.0, 1.0) var stretch_amount = .1
export var stretch_speed = 0.2

onready var squash_vector = Vector2(1.0 + squash_amount, 1.0 - squash_amount)
onready var stretch_vector = Vector2(1.0 - stretch_amount, 1.0 + stretch_amount)

func _ready():
	$"%Orientation".connect("orientation_updated", self, "orientation_updated")


func squash():
	remove_all()

	parent.scale.y = resting_scale.y
	parent.scale.x = resting_scale.x * sign(parent.scale.x)
	
	var goal_vector = Vector2(resting_scale.x * sign(parent.scale.x), resting_scale.y)
	
	interpolate_method(self, "apply_squash", 0, 1, stretch_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	start()


func stretch():
	remove_all()
	
	parent.scale.y = resting_scale.y
	parent.scale.x = resting_scale.x * sign(parent.scale.x)
	
	interpolate_method(self, "apply_stretch", 0, 1, stretch_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	start()


func apply_stretch(t: float):
	var current_x_sign = sign(parent.scale.x)
	var interp_stretch = stretch_vector.linear_interpolate(Vector2.ONE, t)
	
	parent.scale.x = abs(resting_scale.x) * interp_stretch.x * current_x_sign
	parent.scale.y = resting_scale.y * interp_stretch.y


func apply_squash(t: float):
	var current_x_sign = sign(parent.scale.x)
	var interp_squash = squash_vector.linear_interpolate(Vector2.ONE, t)
	
	parent.scale.x = abs(resting_scale.x) * interp_squash.x * current_x_sign
	parent.scale.y = resting_scale.y * interp_squash.y


func orientation_updated(orientation: int):
	parent.scale.x = resting_scale.x * orientation
	parent.scale.y = resting_scale.y
	remove_all()
