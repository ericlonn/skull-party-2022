extends BaseState

var attack_connected = false
var attack_force = Vector2(1000,-1000)
var attack_direction = 0

func enter():
	player.attack()
	attack_direction = sign(player.orientation.scale.x)
	
	player.punch.monitoring = true
	player.punch.monitorable = true
	player.punch.visible = true
	player.animator.play("punch")
	
	player.sprite_echo_generator.enabled = true

func process(delta: float):
	if player.attack_timer.time_left <= 0:
		return State.Idle
	
	if attack_connected:
		attack_connected = false
		return State.Run
	

	return State.Null


func physics_process(delta):
#	player.apply_gravity(delta)
#	player.apply_x_movement(delta)
#	player.orient_character()
	player.apply_velocity()
	
	return State.Null


func exit():
	player.punch.monitoring = false
	player.punch.monitorable = false
	player.punch.visible = false
	player.sprite_echo_generator.enabled = false


func _on_Punch_body_entered(body):
	if body != player and body is Player:
		body.attacked(player.position, attack_force)
		print(body.name + " attacked!")
		
		player.bonk(body.position)
		
		attack_connected = true
	elif body.get_collision_layer() == 2:
		player.bonk(player.position + Vector2.RIGHT * attack_direction )
		attack_connected = true
