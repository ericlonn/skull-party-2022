extends BaseState

func enter():
	if player.wall_jump_coyote_timer.time_left > 0:
		player.apply_jump(-player.wall_jump_coyote_timer.buffered_wall_slide_x_dir)
	elif player.is_wall_on_right and player.move_direction == 1:
		player.apply_jump(-1)
	elif player.is_wall_on_left and player.move_direction == -1:
		player.apply_jump(1)
	else:
		player.apply_jump()
	player.animator.play("jump")

func process(delta: float):
	if player.stun_triggered:
		return State.Stunned
	
	if player.is_on_floor():
		if player.jump_buffer.time_left > 0:
			return State.Jump
		else:
			return State.Idle
	
	if player.is_wall_on_right and player.move_direction == 1:
		return State.Wall_Slide
	
	if player.is_wall_on_left and player.move_direction == -1:
		return State.Wall_Slide
	
	if player.attack_pressed:
		return State.Attack
	
	if player.velocity.y > 0:
		return State.Fall
	
	return State.Null

func physics_process(delta: float):
	player.apply_gravity()
	player.apply_x_movement()
	player.orient_character()
	player.apply_velocity()
	
	return State.Null
