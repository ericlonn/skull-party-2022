extends BaseState

func enter():
	player.play_animation("run")

func process(delta: float):
	if player.is_dead:
		return State.Dead
	
	if player.stun_triggered:
		return State.Stunned
	
	if player.jump_pressed:
		return State.Jump
	
	if player.attack_pressed:
		return State.Attack
	
	if player.move_direction == 0:
		return State.Idle
	
	if not player.is_on_floor():
		player.coyote_timer.start()
		return State.Fall
	
	return State.Null

func physics_process(delta: float):
	player.apply_gravity()
	
	player.apply_x_movement()
	player.orient_character()
	player.apply_velocity()
	
	choose_animation()
	
	return State.Null
	
func choose_animation():
	if player.move_direction != sign(player.velocity.x) and abs(player.velocity.x) > 0.0:
		player.play_animation("slide")
		player.slide_particles.emitting = true
	else:
		player.play_animation("run")
		player.slide_particles.emitting = false

func exit():
	player.slide_particles.emitting = false
