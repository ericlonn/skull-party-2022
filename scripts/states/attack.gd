extends BaseState

func enter():
	player.attack_line.visible = true
	player.sprite.play("fall")
	
	player.attack()

func process(delta: float):
	if player.attack_timer.time_left <= 0:
		return State.Idle

#	player.apply_gravity(delta)
#	player.apply_x_movement(delta)
#	player.orient_character()
#	player.calculate_applied_force(delta)
	player.apply_velocity()
	return State.Null

func exit():
	player.attack_line.visible = false
