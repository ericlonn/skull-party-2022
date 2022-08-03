extends Node2D

onready var bg_splat := $BGSplat
onready var fg_splat := $FGSplat

var bg_alpha = 0.4
var fg_alpha = 0.9

var texture setget set_texture
var color setget set_color

func set_texture(value):
	texture = value
	fg_splat.texture = texture
	bg_splat.texture = texture
	

func set_color(value):
	color = value
	
	fg_splat.modulate = color
	bg_splat.modulate = color
	
	bg_splat.modulate.a = bg_alpha
	fg_splat.modulate.a = fg_alpha
