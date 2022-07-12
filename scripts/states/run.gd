extends BaseState

func enter():
	player.sprite.play("run")

func process(delta: float):
	if player.jump_pressed:
		return State.Jump
	
	if player.attack_pressed:
		return State.Attack
	
	if player.move_direction == 0:
		return State.Idle
	return State.Null

func physics_process(delta: float):
	player.apply_gravity(delta)
	
	player.apply_x_movement(delta)
	player.orient_character()
	player.calculate_applied_force(delta)
	player.apply_velocity()
	return State.Null
