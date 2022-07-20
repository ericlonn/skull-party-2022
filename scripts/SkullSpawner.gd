extends Node

export(PackedScene) var powerskull_scene
onready var rng = RandomNumberGenerator.new()

func _ready():
	Events.connect("skull_lost", self, "_on_Player_skull_lost")
	rng.randomize()

func _on_Player_skull_lost(player, skull_type):
	var spawn_position = player.global_position
	spawn_position.y += -100
	spawn_skull(skull_type, spawn_position, true)

func spawn_skull(type: int = -1, spawn_position: Vector2 = Vector2.ZERO, launch_skull: bool = false):
	var new_skull = powerskull_scene.instance()
	if type == -1:
		new_skull.powerskull_type = rng.randi_range(0, 2)
	else:
		new_skull.powerskull_type = type
	
	if spawn_position != Vector2.ZERO:
		new_skull.manually_set_position(spawn_position)
	
	if launch_skull:
		var launch_force: Vector2 = new_skull.launch_speed
		var random_angle_rads = deg2rad(new_skull.launch_random_angle)
		var launch_force_rotation = rng.randf_range(-random_angle_rads, random_angle_rads)
		
		launch_force = launch_force.rotated(launch_force_rotation)
		print(launch_force)
		
		new_skull.apply_impulse(Vector2.ZERO, launch_force)
	
	get_parent().add_child(new_skull)
