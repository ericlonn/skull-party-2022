extends Ammo

var move_speed = 1500

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	translate(Vector2.RIGHT * move_speed * firing_direction * delta)
