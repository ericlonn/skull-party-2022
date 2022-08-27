extends BaseState

var weapon_state: BaseState

func enter():
	if player.weapon_slot.super_weapon.used_state != null:
		weapon_state = player.weapon_slot.super_weapon.used_state
	
	if weapon_state != null:
		get_parent().states[BaseState.State.Weapon] = weapon_state
	else:
		player.weapon_slot.fire_weapon()
	
	player.attack_limit_timer.start()
	

func process(delta):
	if weapon_state != null:
		return State.Weapon
	
	if player.is_dead:
		return State.Dead
	
	return State.Idle

func physics_process(delta):
	player.movement.apply_gravity()
	player.movement.apply_x_movement()
	player.orientation.orient_character()
	player.movement.apply_velocity()
	return State.Null


func exit():
	weapon_state = null
