extends Node2D
class_name SuperWeapon

export(PackedScene) var ammo_scene

var bullet_spawn_point: Node2D
var parent_player: Player

func fire():
	var ammo_instance: Ammo = ammo_scene.instance()
	ammo_instance.global_position = bullet_spawn_point.global_position
	ammo_instance.firing_direction = sign(parent_player.orientation.scale.x)
	
	add_child(ammo_instance)
