extends BaseState



func enter():
	player.animator.play("fall")
	var animation_length = player.animator.current_animation_length
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	player.animator.seek(rnd.randf_range(0.0, animation_length), true)


func process(delta: float):
	if player.stun_triggered:
		return State.Stunned
	
	var has_coyote_time = true if player.coyote_timer.time_left > 0 else false
		
	if player.jump_pressed and has_coyote_time:
		return State.Jump
	
	if player.is_wall_on_right and player.move_direction == 1:
		return State.Wall_Slide
	
	if player.is_wall_on_left and player.move_direction == -1:
		return State.Wall_Slide
	
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
	player.apply_velocity()
	
	return State.Null
