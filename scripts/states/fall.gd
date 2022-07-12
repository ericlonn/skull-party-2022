extends BaseState

func enter():
	player.sprite.play("fall")

func process(delta: float):
	if player.is_on_floor():	
		if player.jump_buffer.time_left > 0:
			return State.Jump
		else:
			return State.Idle
	
	if player.attack_pressed:
		return State.Attack
	
	return State.Null

func physics_process(delta: float):
	player.apply_gravity(delta)
	player.apply_x_movement(delta)
	player.orient_character()
	player.calculate_applied_force(delta)
	player.apply_velocity()
	
	return State.Null
