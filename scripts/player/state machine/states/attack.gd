extends BaseState

var attack_disabled = false
var use_superweapon = false

func enter():
	if player.attack_limit_timer.time_left > 0:
		attack_disabled = true
		return
	
	if player.is_powered_up:
		use_superweapon = true
	else:
		use_superweapon = false

func process(delta: float):
	if player.is_dead:
		return State.Dead
	
	if attack_disabled:
		return State.Idle
	
	if use_superweapon:
		return State.Fire_Weapon
	else:
		return State.Punch


func exit():
	attack_disabled = false
