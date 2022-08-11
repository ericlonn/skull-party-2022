extends BaseState



func enter():
	player.visuals.play_animation("fall")
	var animation_length = player.visuals.animator.current_animation_length
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	player.visuals.animator.seek(rnd.randf_range(0.0, animation_length), true)


func process(delta: float):
	if player.is_dead:
		return State.Dead
	
	if player.stun_triggered:
		return State.Stunned
	
	var has_coyote_time = true if \
	player.coyote_timer.time_left > 0 or \
	player.wall_jump_coyote_timer.time_left > 0 \
	else false
		
	if player.input.jump_pressed and has_coyote_time:
		return State.Jump
	
	if player.movement.is_wall_on_right and player.input.move_direction == 1:
		return State.Wall_Slide
	
	if player.movement.is_wall_on_left and player.input.move_direction == -1:
		return State.Wall_Slide
	
	if player.is_on_floor():
		if player.jump_buffer.time_left > 0:
			return State.Jump
		else:
			player.visuals.squash()
			return State.Idle
	
	if player.input.attack_pressed:
		return State.Attack
	
	return State.Null

func physics_process(delta: float):
	player.movement.apply_gravity()
	player.movement.apply_x_movement()
	player.orientation.orient_character()
	player.movement.apply_velocity()
	
	return State.Null
