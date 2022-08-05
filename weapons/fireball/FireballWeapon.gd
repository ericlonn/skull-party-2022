extends SuperWeapon

func fire():
	.fire()
	
	player.lose_powerskull(true)
	
	Fmod.play_one_shot("event:/Weapons/Fireball", self)
