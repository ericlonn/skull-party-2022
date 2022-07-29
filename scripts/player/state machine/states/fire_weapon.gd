extends BaseState

func enter():
	player.weapon_slot.fire_weapon()
	player.attack_limit_timer.start()

func process(delta):
	return State.Idle

func physics_process(delta):
	player.apply_gravity()
	player.apply_x_movement()
	player.orient_character()
	player.apply_velocity()
	return State.Null
