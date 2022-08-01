extends BaseState

var wall_slide_x_dir = 0
var min_y_velocity_on_entry = -300.0
var max_y_velocity_on_entry = 150.0

func enter():
	player.animator.play("wall_slide")
	
	if player.is_wall_on_right and player.move_direction == 1:
		wall_slide_x_dir = 1
	
	if player.is_wall_on_left and player.move_direction == -1:
		wall_slide_x_dir = -1
	
	if player.velocity.y < min_y_velocity_on_entry:
		player.velocity.y = min_y_velocity_on_entry
	
	if player.velocity.y > max_y_velocity_on_entry:
		player.velocity.y = max_y_velocity_on_entry
	

func process(delta):
	if player.is_dead:
		return State.Dead
	
	if player.is_wall_on_left == false and wall_slide_x_dir == -1:
		return State.Idle
		
	if player.is_wall_on_right == false and wall_slide_x_dir == 1:
		return State.Idle
	
	if player.move_direction == -wall_slide_x_dir:
		return State.Idle
		
	if player.move_direction == 0:
		return State.Idle
	
	if player.is_on_floor():
		return State.Idle
	
	if player.jump_pressed:
		player.position.x += -5 * wall_slide_x_dir
		return State.Jump
	
	if player.attack_pressed:
		player.flip_orientation()
		return State.Attack
	
	return State.Null


func exit():
	if player.is_on_floor() == false:
		player.wall_jump_coyote_timer.start()
		player.wall_jump_coyote_timer.buffered_wall_slide_x_dir = wall_slide_x_dir


func physics_process(delta):
	player.apply_gravity(true)
	player.apply_x_movement()
	player.orient_character()
	player.apply_velocity()
	
	return State.Null
