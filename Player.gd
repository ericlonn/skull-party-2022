extends KinematicBody2D

onready var debug_label = $DebugLabel
onready var state_machine = $StateMachinePlayer

var velocity = Vector2.ZERO

var gravity = 3000.0
var gravity_max_speed = 1800.0

var move_speed = 1500.0
var move_max_speed = 1000.0
var slow_down_speed = 5000.0
var zero_out_range = 70.0

var jump_force = 1200.00

var move_left_input = 0
var move_right_input = 0
var move_direction = 0
var jump_pressed = false

var applied_force = Vector2.ZERO

func _process(delta):
	gather_input()
	
func _physics_process(delta):
	apply_gravity()
	
	if jump_pressed:
		apply_jump()
	
	apply_x_movement()
	
	if Input.is_action_just_pressed("debug_button"):
		applied_force += Vector2(1500.0, -2000.0)
	
	velocity = move_and_slide(velocity + applied_force, Vector2.UP)
	debug_label.text = int(applied_force.x) as String
	
#	applied_force = applied_force.slerp(Vector2.ZERO, 0.01 * delta)
#	applied_force.x = lerp(applied_force.x, 0.0, 0.7)
#	applied_force.y = lerp(applied_force.y, 0.0, 0.7)
	applied_force.round()

func gather_input():
	move_left_input = Input.is_action_pressed("move_left") as int * -1
	move_right_input = Input.is_action_pressed("move_right") as int
	move_direction =  move_left_input + move_right_input
	jump_pressed = Input.is_action_just_pressed("jump")

func apply_gravity():
	if velocity.y <= gravity_max_speed:
		velocity.y += gravity * get_physics_process_delta_time()

func apply_jump():
	if is_on_floor():
		velocity.y += -jump_force

func apply_x_movement():
	if abs(velocity.x) <= zero_out_range and move_direction == 0:
		velocity.x = lerp(velocity.x, 0, 0.9)
		velocity.x = round(velocity.x)
	
	if sign(move_direction) != 0.0 and sign(move_direction) != sign(velocity.x) and applied_force.is_equal_approx(Vector2.ZERO):
		velocity.x = 0.0
	
	if move_direction != 0 and abs(velocity.x) <= move_max_speed:
		velocity.x += move_speed * move_direction * get_physics_process_delta_time()
	else:
		velocity.x += slow_down_speed * -sign(velocity.x) * get_physics_process_delta_time()
