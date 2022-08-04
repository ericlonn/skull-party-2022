extends Node

onready var noise := OpenSimplexNoise.new()
onready var camera := get_parent()
onready var initial_offset = camera.offset

var time = 0

var x_amplitude := 15.0
var y_amplitude := 15.0
var rot_amplitude := 0.0

var x_speed := 1500.0
var y_speed := 1500.0
var rot_speed := 1500.0

var default_duration = 0.3

func _process(delta):
	if time > 0:
		var noise_sample = Vector3.ZERO
		noise_sample.x = noise.get_noise_3d(time * x_speed, 0, 0)
		noise_sample.y = noise.get_noise_3d(0, time * y_speed, 0)
		noise_sample.z = noise.get_noise_3d(0, 0, time * rot_speed)
		
		camera.offset.x = initial_offset.x + noise_sample.x * x_amplitude
		camera.offset.y = initial_offset.y + noise_sample.y * y_amplitude
		camera.rotation_degrees = 0.0 + noise_sample.z * rot_amplitude
		
		time -= delta
	else:
		time = 0
		camera.offset = initial_offset
		camera.rotation_degrees = 0
		set_process(false)

func shake(duration: float = default_duration):
	time = duration
	set_process(true)
