extends Sprite

onready var tween: Tween = $Tween
var begin_color = Color(1,.5,0,.75)
var end_color = Color(1,0,1,0)
var fade_time = 0.4
var spawn_position = Vector2.ZERO

func _ready():
	modulate = begin_color
	global_position = spawn_position
	tween.interpolate_property(self, "modulate", begin_color, end_color, fade_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()

func _process(delta):
	global_position = spawn_position
