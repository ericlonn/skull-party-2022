extends BaseState

func enter():
	player.animator.play("run")

func process(delta: float):
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
	player.apply_gravity(delta)
	
	player.apply_x_movement(delta)
	player.orient_character()
	player.apply_velocity()
	
	choose_animation()
	
	return State.Null
	
func choose_animation():
	if player.move_direction != sign(player.velocity.x) and abs(player.velocity.x) > 0.0:
		player.animator.play("slide")
		player.slide_particles.emitting = true
	else:
		player.animator.play("run")
		player.slide_particles.emitting = false

func exit():
	player.slide_particles.emitting = false
