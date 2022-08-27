extends SuperWeapon

func fire():
	.fire()
	
	player.lose_powerskull(true)
