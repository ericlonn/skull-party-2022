extends Node2D
class_name SuperWeapon

export(PackedScene) var ammo_scene

var bullet_spawn_point: Node2D
var player: Player
var used_state: BaseState

func _ready():
	for child in get_children():
		if child is BaseState:
			used_state = child


func fire():
	var ammo_instance = ammo_scene.instance()
	ammo_instance.global_position = bullet_spawn_point.global_position
	ammo_instance.firing_direction = sign(player.orientation.scale.x)
	ammo_instance.player = player
	ammo_instance.color = Globals.get_player_color(player.id)
	
	bullet_spawn_point.add_child(ammo_instance)
