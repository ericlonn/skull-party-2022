extends Node2D

export(Array, SpriteFrames) var sprite_frames

onready var bg_splat := $BGSplat
onready var fg_splat := $FGSplat

var bg_alpha = 0.8
var fg_alpha = 0.4

var selected_frames setget set_frames
var color setget set_color

var rng := Globals.rng

func _ready():
	rotation = rng.randf_range(0,360)
	
	var random_frame_index = rng.randi_range(0, sprite_frames.size() - 1)
	set_frames(sprite_frames[random_frame_index])
	
	bg_splat.rotation_degrees = rotation_degrees
	fg_splat.rotation_degrees = rotation_degrees
	
	bg_splat.play()
	fg_splat.play()


func set_frames(value):
	selected_frames = value
	fg_splat.frames = selected_frames
	bg_splat.frames = selected_frames
	

func set_color(value):
	color = value
	
	fg_splat.modulate = color
	bg_splat.modulate = color
	
	bg_splat.modulate.a = bg_alpha
	fg_splat.modulate.a = fg_alpha
