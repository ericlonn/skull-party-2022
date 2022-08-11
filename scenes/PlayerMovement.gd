extends Node

onready var player = owner

onready var right_wall_check = $"%RightWallCheck"
onready var left_wall_check = $"%LeftWallCheck"

var velocity = Vector2.ZERO

var gravity = 3000.0
var gravity_max_speed = 1800.0

var move_speed = 550.0
var move_accel = 1900.0
var move_max_speed = 3000.0
var slow_down_speed = 2500.0
var change_x_dir_modifier = 1.4

var air_control_speed = 1900.0

var head_bump_correction_margin = 14

var bonk_speed = Vector2(700.0, -450.0)

var is_wall_on_left setget , get_is_wall_on_left
var is_wall_on_right setget , get_is_wall_on_right

export var jump_height : float = 175.0
export var jump_time_to_peak : float = 0.3
export var jump_time_to_descent : float = 0.25
export var jump_held_modifier = 0.6
export var wall_slide_gravity_modifier = 0.1

var wall_jump_x_force = 400.0
var wall_jump_x_move_reduction_direction = 0
var wall_jump_x_move_reduction_length= 0.25
var wall_jump_x_move_reduction_timer = 0.0

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _physics_process(delta):
	# timer started at wall jump to prevent player from moving back toward a wall they just jumped off of
	if wall_jump_x_move_reduction_timer > 0:
		wall_jump_x_move_reduction_timer -= delta
	else:
		wall_jump_x_move_reduction_direction = 0


func apply_gravity(wall_slide: bool = false):
	var delta = get_physics_process_delta_time()

	if velocity.y <= gravity_max_speed:
		if wall_slide:
			velocity.y += get_gravity() * delta * wall_slide_gravity_modifier
		else:
			velocity.y += get_gravity() * delta


func get_gravity():
	var modifier = jump_held_modifier if player.input.is_jump_button_held else 1.0
	return jump_gravity * modifier if velocity.y < 0.0 else fall_gravity
	

func apply_jump(wall_jump_x_dir = 0):
	player.visuals.stretch()
	if wall_jump_x_dir != 0:
		wall_jump_x_move_reduction_direction = wall_jump_x_dir * -1
		wall_jump_x_move_reduction_timer = wall_jump_x_move_reduction_length
		velocity.x += wall_jump_x_force * wall_jump_x_dir

		if player.input.move_direction == 0:
			player.orientation.orient_character(wall_jump_x_dir)

	velocity.y = jump_velocity


func apply_x_movement():
	var delta = get_physics_process_delta_time()
	var move_direction = player.input.move_direction
	
	if player.is_on_floor():
		if move_direction != 0 and sign(move_direction) == sign(velocity.x):
			velocity.x = move_toward(velocity.x, move_speed * move_direction, move_accel * delta)
		elif move_direction != 0 and sign(move_direction) == -sign(velocity.x):
			velocity.x = move_toward(velocity.x, move_speed * move_direction, move_accel * change_x_dir_modifier * delta)
		else:
			velocity.x = move_toward(velocity.x, move_speed * move_direction, slow_down_speed * delta)
	else:
		if move_direction != 0 and move_direction != wall_jump_x_move_reduction_direction:
			velocity.x = move_toward(velocity.x, move_speed * move_direction, air_control_speed * delta)


func apply_velocity():
	if velocity.y < 0:
		head_bump_correction(head_bump_correction_margin)

	velocity = player.move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)

	for i in player.get_slide_count():
		handle_collision(player.get_slide_collision(i))


func handle_collision(collision):
	var collider  = collision.collider
	if collider.is_in_group("players"):
		bonk(collider.position)
	if collider is Chest:
		collider.attacked(collider.global_position.x - player.global_position.x)
		bonk(collider.global_position)


func head_bump_correction(margin_pixels: int):
	var delta = get_physics_process_delta_time()
	var next_y_step = Vector2(0, velocity.y * delta)
	var global_transform = player.global_transform

	if player.test_move(global_transform, next_y_step):
		for i in margin_pixels:
			for j in [-1, 1]:
				var test_transform = global_transform.translated(Vector2((i*j), 0))
				if !player.test_move(test_transform, next_y_step):
					var new_translate = Vector2((i*j), 0)
					player.translate(new_translate)
					return


func bonk(bonked_from_position: Vector2):
	print("bonk " + name as String)
	var bonk_vector = player.position - bonked_from_position
	var bonk_x_dir = sign(bonk_vector.x)
	velocity.x =  bonk_speed.x * bonk_x_dir
	velocity.y = bonk_speed.y
	
	Fmod.play_one_shot("event:/Player/Bonk", self)


func get_is_wall_on_left():
	return left_wall_check.is_colliding()


func get_is_wall_on_right():
	return right_wall_check.is_colliding()
