tool
extends Node

onready var rng := RandomNumberGenerator.new()

enum powerskull_types {RED, GREEN, BLUE}
var camera setget , get_camera

var weapons = [
	"res://weapons/bigpunch/BigPunchWeapon.tscn",
	"res://weapons/fireball/FireBallWeapon.tscn",
	"res://weapons/grenade/GrenadeWeapon.tscn",
	"res://weapons/shotgun/ShotgunWeapon.tscn"
]

func _ready():
	rng.randomize()


func get_skull_color(skull_type: int = -1) -> Color:
	if skull_type < 0 or skull_type > powerskull_types.size() - 1:
		return Color(0,0,0,1)
	
	match skull_type:
		0:
			return Color.lightcoral
		1:
			return Color.lightgreen
		2:
			return Color.cyan
		
	return Color(0,0,0,1)

func get_player_color(player_id: int) -> Color:
	match player_id:
		1:
			return Color.deeppink
		2:
			return Color.coral
		3:
			return Color.deepskyblue
		4:
			return Color.mediumspringgreen
	
	return Color.brown


func get_camera() -> Camera2D:
	var cameras = get_tree().get_nodes_in_group("cameras")
	
	for camera in cameras:
		if camera is Camera2D and camera.current:
			return camera
	
	return null


func get_weapon():
	var rand_index = rng.randi_range(0, weapons.size() - 1)
	return weapons[rand_index]
