extends Node

onready var skull_spawn_timer: Timer = $SkullSpawnTimer
export(float) var skull_spawn_interval = 10
export(float) var skull_spawn_variation = 2
export(int) var furthest_point_variation = 5

var skull_spawn_points = []

export(PackedScene) var powerskull_scene
export(float) var powerskull_spawn_chance = 3.0
export(PackedScene) var chest_scene
export(float) var chest_spawn_chance = 1.0

onready var rng = RandomNumberGenerator.new()

var red_count = 0
var blue_count = 0
var green_count = 0

func _ready():
	Events.connect("skull_lost", self, "_on_Player_skull_lost")
	Events.connect("chest_shattered", self, "_on_chest_shattered")
	
	skull_spawn_timer.wait_time = skull_spawn_interval + rng.randf_range(-skull_spawn_variation, skull_spawn_variation)
	skull_spawn_timer.start()
	
	for child in get_children():
		if child is SkullSpawnPoint:
			skull_spawn_points.append(child)
	
	rng.randomize()

func _on_Player_skull_lost(player, skull_type, skull_as_ammo):
	if skull_as_ammo:
		return

	var spawn_position = player.global_position
	spawn_position.y += -32
	spawn_skull(spawn_position, skull_type, true)



func spawn_skull(spawn_position: Vector2, type: int = -1, launch_skull: bool = false):
	var new_skull = powerskull_scene.instance()
	if type == -1:
		new_skull.powerskull_type = rng.randi_range(0, Globals.powerskull_types.size() - 1)
	else:
		new_skull.powerskull_type = type
	
	if spawn_position != Vector2.ZERO:
		new_skull.manually_set_position(spawn_position)
	
	if launch_skull:
		var launch_force: Vector2 = new_skull.launch_speed
		var random_angle_rads = deg2rad(new_skull.launch_random_angle)
		var launch_force_rotation = rng.randf_range(-random_angle_rads, random_angle_rads)
		
		launch_force = launch_force.rotated(launch_force_rotation)
		
		new_skull.apply_impulse(Vector2.ZERO, launch_force)
	
	get_parent().add_child(new_skull)


func spawn_chest(spawn_position: Vector2):
	var new_chest = chest_scene.instance()
	new_chest.global_position = spawn_position
	
	get_parent().add_child(new_chest)
	


func _on_chest_shattered(chest):
	spawn_skull(chest.global_position, -1, true)


func _on_SkullSpawnTimer_timeout():
	var current_players = get_tree().get_nodes_in_group("players")
	var avg_player_pos = Vector2.ZERO
	
	for player in current_players:
		avg_player_pos += player.global_position
	
	avg_player_pos /= current_players.size()
	
	var furthest_spawn_points = []
	for spawn_point in skull_spawn_points:
		if furthest_spawn_points.size() < furthest_point_variation:
			furthest_spawn_points.append(spawn_point)
		else:
			var spawn_point_distance = spawn_point.global_position.distance_to(avg_player_pos)
			var point_to_remove_index = -1
			for i in furthest_spawn_points.size():
				var cur_point_distance = furthest_spawn_points[i].global_position.distance_to(avg_player_pos)
				if spawn_point_distance > cur_point_distance:
					point_to_remove_index = i
			
			if point_to_remove_index != -1:
				furthest_spawn_points.remove(point_to_remove_index)
				furthest_spawn_points.append(spawn_point)
	
	var new_spawn_point = furthest_spawn_points[rng.randi_range(0, furthest_spawn_points.size() - 1)]
	
	var weighted_bag = RNGTools.WeightedBag.new()
	weighted_bag.weights = {
		spawn_skull = powerskull_spawn_chance,
		spawn_chest = chest_spawn_chance}
	
	var weighted_result = RNGTools.pick_weighted(weighted_bag)
	funcref(self, weighted_result).call_func(new_spawn_point.global_position)
