class_name Player
extends KinematicBody2D

onready var debug_label = $DebugLabel
onready var sprite = $AnimatedSprite


var velocity = Vector2.ZERO

var gravity = 3000.0
var gravity_max_speed = 1800.0

var move_speed = 1000.0
var move_accel = 3500.0
var move_max_speed = 6000.0
var slow_down_speed = 5000.0

var jump_force = 1200.00

var applied_force = Vector2.ZERO
var applied_force_air_resist = 1000.0

var move_left_input = 0
var move_right_input = 0
var move_direction = 0
var jump_pressed = false

export var enabled = true
export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _process(delta):
	gather_input()
	
func _physics_process(delta):
	apply_gravity(delta)
	
	if enabled:
		if jump_pressed:
			apply_jump()
		apply_x_movement(delta)
	
	orient_character()
	calculate_applied_force(delta)
	
	if Input.is_action_just_pressed("debug_button"):
		applied_force = Vector2(300.0, -600.0)
	
	apply_velocity()
	debug_label.text = applied_force as String

func gather_input():
	move_left_input = Input.is_action_pressed("move_left") as int * -1
	move_right_input = Input.is_action_pressed("move_right") as int
	move_direction =  sign(move_left_input + move_right_input)
	jump_pressed = Input.is_action_just_pressed("jump")

func apply_gravity(delta):
	if velocity.y <= gravity_max_speed:
		velocity.y += get_gravity() * delta

func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func apply_jump():
	if is_on_floor():
		velocity.y += jump_velocity

func apply_x_movement(delta):
	if move_direction != 0:
		velocity.x = move_toward(velocity.x, move_speed * move_direction, move_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, move_speed * move_direction, slow_down_speed * delta)

func calculate_applied_force(delta):
	if is_on_floor():
		applied_force.x = move_toward(applied_force.x, 0.0, slow_down_speed * delta)
	else:
		applied_force.x = move_toward(applied_force.x, 0.0, applied_force_air_resist * delta)
	
	applied_force.y = move_toward(applied_force.y, 0.0, get_gravity() * delta)
	
func orient_character():
	match move_direction:
		1:
			sprite.flip_h = false
		-1:
			sprite.flip_h = true

func apply_velocity():
	velocity = move_and_slide(velocity + applied_force, Vector2.UP)
