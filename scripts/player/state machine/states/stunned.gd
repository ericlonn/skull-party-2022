extends BaseState

onready var rng = RandomNumberGenerator.new()

var stun_over = false
var stun_movement_x = 0

var initial_bounce_vector = Vector2(400.0, -600.0)
var current_bounce_vector = Vector2.ZERO
var bounce_degradation = 125

func enter():
	player.stun_triggered = false
	player.animator.play("stunned")
	player.stun_timer.start()
	player.sprite.modulate = Color(1,1,1,0.5)
	stun_movement_x = sign(player.velocity.x)
	
	current_bounce_vector = initial_bounce_vector
	
	#collide with chests
	player.set_collision_mask_bit(3, true)

func process(delta):
	if stun_over:
		return State.Idle

	return State.Null


func physics_process(delta):
	var wall_bonk_triggered = false
	
	if stun_movement_x == 0:
		stun_movement_x = ( rng.randi_range(0,1) * 2 ) - 1
	
	for i in player.get_slide_count():
		var collision = player.get_slide_collision(i)
		if collision.collider.get_collision_layer() == 2 and player.is_on_wall() and wall_bonk_triggered == false:
			stun_movement_x *= -1
			bounce()
			wall_bonk_triggered = true

		if wall_bonk_triggered == false:
			if collision.collider.get_collision_layer() == 2 and collision.normal.y < 0:
				bounce()
			elif collision.collider.get_collision_layer() != 2:
				bounce()
				if sign(collision.collider.position.x - player.position.x) == stun_movement_x:
					stun_movement_x *= -1
			
	player.debug_label.text = stun_movement_x as String
	
	player.apply_gravity()
#	player.apply_x_movement()
	player.orient_character(stun_movement_x)
	player.apply_velocity()
	
	return State.Null


func bounce():
	var bounce_x_dir = sign(stun_movement_x)
	player.velocity.x =  current_bounce_vector.x * bounce_x_dir
	player.velocity.y = current_bounce_vector.y
	
	current_bounce_vector = current_bounce_vector.move_toward(Vector2.ZERO, bounce_degradation)

func exit():
	stun_over = false
	player.sprite.modulate = Color.white
	
	#no longer collide with chests
	player.set_collision_mask_bit(3, true)


func _on_StunTimer_timeout():
	stun_over = true
	
