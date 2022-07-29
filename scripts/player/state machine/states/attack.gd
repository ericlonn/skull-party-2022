extends BaseState

var use_superweapon = false

func enter():
	if player.is_powered_up:
		use_superweapon = true
	else:
		use_superweapon = false

func process(delta: float):
	if use_superweapon:
		return State.Fire_Weapon
	else:
		return State.Punch
