extends BaseState

func enter():
	if player.wall_jump_coyote_timer.time_left > 0:
		player.movement.apply_jump(-player.wall_jump_coyote_timer.buffered_wall_slide_x_dir)
	elif player.movement.is_wall_on_right and player.input.move_direction == 1:
		player.movement.apply_jump(-1)
	elif player.movement.is_wall_on_left and player.input.move_direction == -1:
		player.movement.apply_jump(1)
	else:
		player.movement.apply_jump()
	player.visuals.play_animation("jump")
	Fmod.play_one_shot("event:/Player/Jump", self)

func process(delta: float):
	if player.is_dead:
		return State.Dead
	
	if player.stun_triggered:
		return State.Stunned
	
	if player.is_on_floor():
		if player.jump_buffer.time_left > 0:
			return State.Jump
		else:
			return State.Idle
	
	if player.movement.is_wall_on_right and player.input.move_direction == 1:
		return State.Wall_Slide
	
	if player.movement.is_wall_on_left and player.input.move_direction == -1:
		return State.Wall_Slide
	
	if player.input.attack_pressed:
		return State.Attack
	
	if player.movement.velocity.y > 0:
		return State.Fall
	
	return State.Null

func physics_process(delta: float):
	player.movement.apply_gravity()
	player.movement.apply_x_movement()
	player.orientation.orient_character()
	player.movement.apply_velocity()
	
	return State.Null
