extends Node2D

var move_weight = 4
var rot_weight = 2

var target_node: Node2D

func _physics_process(delta):
	global_position = lerp(global_position, target_node.global_position, move_weight * delta)
	
	var angle_to_target = global_position.angle_to(target_node.global_position)
	print(str(global_rotation) + " - " + str(angle_to_target))
	global_rotation = lerp_angle(global_rotation, angle_to_target, rot_weight * delta)
