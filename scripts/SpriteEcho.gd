extends Sprite

onready var tween: Tween = $Tween
var begin_color = Color(1,.5,0,.75)
var end_color = Color(1,0,1,0)
var fade_time = 0.4
var spawn_position = Vector2.ZERO
var color_gradient: Gradient

func _ready():
	if color_gradient == null:
		color_gradient = Gradient.new()
		color_gradient.offsets = [0, 1]
		color_gradient.colors = [begin_color, end_color]
	
	global_position = spawn_position
	tween.interpolate_method(self, "set_color", 0.0, 1.0, fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()


func _process(delta):
	global_position = spawn_position


func set_color(time):
	var color = color_gradient.interpolate(time)
	material.set_shader_param("Fill_Color", color)
