class_name Player
extends KinematicBody2D

signal set_as_root

onready var debug_label: Label = $DebugLabel
onready var sprite: Sprite = $Orientation/Sprite
onready var sprite_echo_generator: Node2D = $SpriteEchoGenerator
onready var animator: AnimationPlayer = $Orientation/Sprite/AnimationPlayer
onready var state_manager := $State_Manager

onready var jump_buffer: Timer = $Timers/JumpBuffer
onready var stun_timer: Timer = $Timers/StunTimer
onready var coyote_timer: Timer = $Timers/CoyoteTimer
onready var wall_jump_coyote_timer: Timer = $Timers/WallJumpCoyoteTimer
onready var attack_limit_timer: Timer = $Timers/AttackLimitTimer
onready var hit_stop_timer: Timer = $Timers/HitStopTimer


onready var orientation: Node2D = $Orientation
onready var punch: Area2D = $Orientation/Punch
onready var debug_line: Line2D = $DebugLine
onready var slide_particles: Particles2D = $VisualElements/SlideParticles
onready var right_wall_check = $RightWallCheck
onready var left_wall_check = $LeftWallCheck
onready var powerup_visuals = $VisualElements/PowerUpVisuals
onready var death_visuals := $VisualElements/DeathVisuals
onready var weapon_slot = $Orientation/WeaponSlot

onready var rng = RandomNumberGenerator.new()

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

var move_left_input = 0
var move_right_input = 0
var move_direction = 0

var was_on_floor = false
var is_wall_on_left setget , get_is_wall_on_left
var is_wall_on_right setget , get_is_wall_on_right


var bonk_speed = Vector2(700.0, -450.0)

var rigidbody_push = 300

var jump_pressed = false
var is_jump_button_held = false
var attack_pressed = false
var stun_triggered = false

export var enabled = true
export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float
export var jump_held_modifier = 0.5
export var wall_slide_gravity_modifier = 0.1

var wall_jump_x_force = 400.0
var wall_jump_x_move_reduction_direction = 0
var wall_jump_x_move_reduction_length= 0.25
var wall_jump_x_move_reduction_timer = 0.0

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var id: int setget set_id
var powerskulls = []
var chance_to_lose_skull = 0.5

var health: int = 1 setget set_health
var is_dead = false

var is_powered_up = false
var is_in_hit_stop = false
var is_stunned setget ,get_is_stunned


func _ready():
	emit_signal("set_as_root", self)
	rng.randomize()
	state_manager.init(self)


func _process(delta):
	if powerskulls.size() >= 3:
		power_up()
	
	gather_input()
	state_manager.process(delta)


func _physics_process(delta):
	# timer started at wall jump to prevent player from moving back toward a wall they just jumped off of
	if wall_jump_x_move_reduction_timer > 0:
		wall_jump_x_move_reduction_timer -= delta
	else:
		wall_jump_x_move_reduction_direction = 0

	state_manager.physics_process(delta)


func gather_input():
	if enabled:
		move_left_input = Input.is_action_pressed("move_left" + str(id)) as int * -1
		move_right_input = Input.is_action_pressed("move_right" + str(id)) as int
		move_direction =  sign(move_left_input + move_right_input)
		jump_pressed = Input.is_action_just_pressed("jump" + str(id))
		attack_pressed = Input.is_action_just_pressed("attack" + str(id))

		if jump_pressed:
			jump_buffer.start()

		if jump_pressed and is_on_floor():
			is_jump_button_held = true

		if is_jump_button_held and not Input.is_action_pressed("jump" + str(id)):
			is_jump_button_held = false


func apply_gravity(wall_slide: bool = false):
	var delta = get_physics_process_delta_time()

	if velocity.y <= gravity_max_speed:
		if wall_slide:
			velocity.y += get_gravity() * delta * wall_slide_gravity_modifier
		else:
			velocity.y += get_gravity() * delta


func get_gravity():
	var modifier = jump_held_modifier if is_jump_button_held else 1.0
	return jump_gravity * modifier if velocity.y < 0.0 else fall_gravity


func apply_jump(wall_jump_x_dir = 0):
	orientation.stretch()
	if wall_jump_x_dir != 0:
		wall_jump_x_move_reduction_direction = wall_jump_x_dir * -1
		wall_jump_x_move_reduction_timer = wall_jump_x_move_reduction_length
		velocity.x += wall_jump_x_force * wall_jump_x_dir

		if move_direction == 0:
			orient_character(wall_jump_x_dir)

	velocity.y = jump_velocity


func apply_x_movement():
	var delta = get_physics_process_delta_time()

	if is_on_floor():
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

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)

	for i in get_slide_count():
		handle_collision(get_slide_collision(i))


func head_bump_correction(margin_pixels: int):
	var delta = get_physics_process_delta_time()
	var next_y_step = Vector2(0, velocity.y * delta)

	if test_move(global_transform, next_y_step):
		for i in margin_pixels:
			for j in [-1, 1]:
				var test_transform = global_transform.translated(Vector2((i*j), 0))
				if !test_move(test_transform, next_y_step):
					var new_translate = Vector2((i*j), 0)
					translate(new_translate)
					return


func handle_collision(collision):
	var collider  = collision.collider
	if collider.is_in_group("players"):
		bonk(collider.position)
	if collider is Chest:
		collider.attacked(collider.global_position.x - global_position.x)
		bonk(collider.global_position)


func orient_character(manual_direction = 0):
	if manual_direction == 0:
		match move_direction:
			1:
				orientation.face_right()
			-1:
				orientation.face_left()
	else:
		manual_direction = 1 if manual_direction > 0 else -1
		match manual_direction:
			1:
				orientation.face_right()
			-1:
				orientation.face_left()


func flip_orientation():
	orientation.scale.x = -orientation.scale.x


func attacked(attack_direction: Vector2, attack_force: Vector2):
	if is_stunned:
		return

	var knockback_x_direction = sign(position.x - attack_direction.x)

	knockback_x_direction = knockback_x_direction if knockback_x_direction != 0 else [-1,1][rng.randi_range(0,1)]

	velocity.x =  attack_force.x * knockback_x_direction
	velocity.y = attack_force.y
	stun_triggered = true
	
	
	if rng.randf_range(0.0, 1.0) >= chance_to_lose_skull:
		lose_powerskull()


func bonk(bonked_from_position: Vector2):
	var bonk_vector = position - bonked_from_position
	var bonk_x_dir = sign(bonk_vector.x)
	velocity.x =  bonk_speed.x * bonk_x_dir
	velocity.y = bonk_speed.y
	
	Fmod.play_one_shot("event:/Player/Bonk", self)



func get_is_wall_on_left():
	return left_wall_check.is_colliding()


func get_is_wall_on_right():
	return right_wall_check.is_colliding()


func add_powerskull(powerskull_type: int):
	if powerskulls.size() < 3:
		powerskulls.append(powerskull_type)
		Events.emit_signal("skull_count_updated", self, powerskulls)


func lose_powerskull(skull_as_ammo := false):
	if powerskulls.size() == 0:
		return
	
	var removed_skull
	
	if powerskulls.size() > 0 and not skull_as_ammo:
		var remove_from_front = true if rng.randi_range(0, 1) == 0 else false
		
		if remove_from_front:
			removed_skull = powerskulls.pop_front()
		else:
			removed_skull = powerskulls.pop_back()
		
		print("removed:" + str(removed_skull))
	elif skull_as_ammo:
		removed_skull = powerskulls.pop_back()
		
		if powerskulls.size() == 0:
			power_down()

	Events.emit_signal("skull_lost", self, removed_skull, skull_as_ammo)
	Events.emit_signal("skull_count_updated", self, powerskulls)

func set_health(value):
	if stun_triggered:
		return
	
	health = clamp(value, 0, 3)
	Events.emit_signal("player_health_updated", self, health)
	
	if health == 0:
		is_dead = true


func set_id(value):
	id = value
	set_child_colors()
	Events.emit_signal("player_id_assigned", self, id)


func set_child_colors():
	var color = Globals.get_player_color(id)
	var player_color_as_plane: Plane = Plane(color.r, color.g, color.b, color.a)
	sprite.material.set_shader_param("outline_colour", player_color_as_plane)
	powerup_visuals.set_color(color)
	death_visuals.set_color(color)
	slide_particles.process_material.color = color


func power_up():
	var weapon_scene = load("res://weapons/fireball/FireBallWeapon.tscn")
	powerup_visuals.enabled = true
	weapon_slot.add_weapon(weapon_scene.instance())
	is_powered_up = true


func power_down():
	var weapon_scene = null
	powerup_visuals.enabled = false
	
	weapon_slot.remove_weapon()
	
	is_powered_up = false


func hit_stop(length := .1):
	set_process(false)
	set_physics_process(false)
	is_in_hit_stop = true
	
	sprite.material.set_shader_param("hit_stop", true)
	
	hit_stop_timer.wait_time = length
	hit_stop_timer.start()
	
	Globals.camera.shake(length)
	
	yield(hit_stop_timer,"timeout")
	
	sprite.material.set_shader_param("hit_stop", false)
	set_process(true)
	set_physics_process(true)
	is_in_hit_stop = false
	

func play_animation(animation_name: String):
	if is_in_hit_stop:
		yield(hit_stop_timer, "timeout")
	
	animator.play(animation_name)


func get_is_stunned():
	if state_manager.current_state != null:
		return state_manager.current_state.name == "stunned"
	else:
		return false
