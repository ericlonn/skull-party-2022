extends BaseState


func enter():
	player.visuals.play_animation("idle")

func process(delta: float):
	if player.is_dead:
		return State.Dead
	
	if player.stun_triggered:
		return State.Stunned
	
	if player.input.jump_pressed:
		return State.Jump
	if player.input.attack_pressed:
		return State.Attack
	if player.input.move_direction != 0:
		return State.Run
	
	if not player.is_on_floor():
		player.coyote_timer.start()
		return State.Fall
	
	return State.Null

func physics_process(delta: float):
	player.movement.apply_gravity()
	player.movement.apply_x_movement()
	player.orientation.orient_character()
	player.movement.apply_velocity()
	return State.Null
