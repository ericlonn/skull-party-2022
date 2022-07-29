extends Node2D
class_name SuperWeapon

export(PackedScene) var ammo_scene

var bullet_spawn_point: Node2D
var parent_player: Player

func fire():
	var ammo_instance: Ammo = ammo_scene.instance()
	ammo_instance.global_position = bullet_spawn_point.global_position
	ammo_instance.firing_direction = sign(parent_player.orientation.scale.x)
	ammo_instance.player = parent_player
	ammo_instance.color = Rules.get_player_color(parent_player.id)
	
	add_child(ammo_instance)
