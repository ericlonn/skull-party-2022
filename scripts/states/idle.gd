extends BaseState


func enter():
	player.animator.play("idle")

func process(delta: float):
	if player.stun_triggered:
		return State.Stunned
	
	if player.jump_pressed:
		return State.Jump
	if player.attack_pressed:
		return State.Attack
	if player.move_direction != 0:
		return State.Run
	
	if not player.is_on_floor():
		player.coyote_timer.start()
		return State.Fall
	
	return State.Null

func physics_process(delta: float):
	player.apply_gravity(delta)
	player.apply_x_movement(delta)
	player.orient_character()
	player.apply_velocity()
	return State.Null
