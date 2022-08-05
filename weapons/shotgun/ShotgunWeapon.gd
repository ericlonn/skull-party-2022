extends SuperWeapon

var pellet_count := 5
var knockback_x_force = 1000

func fire():
	for i in pellet_count:
		.fire()
		
	player.lose_powerskull(true)
	
	var knockback = knockback_x_force * player.orientation.scale.x * -1
	player.velocity.x += knockback
