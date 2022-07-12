class_name Player
extends KinematicBody2D

onready var debug_label = $DebugLabel
onready var sprite = $Orientation/AnimatedSprite
onready var state_manager = $State_Manager
onready var jump_buffer = $JumpBuffer
onready var attack_timer = $AttackTimer
onready var orientation = $Orientation
onready var attack_line = $Orientation/attack_line

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

var attack_speed = 1500.0

var jump_pressed = false
var is_jump_button_held = false
var attack_pressed = false

export var enabled = true
export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float
export var jump_held_modifier = 0.5

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _ready():
	state_manager.init(self)

func _process(delta):
	gather_input()
	state_manager.process(delta)
	
func _physics_process(delta):
	debug_label.text = (get_gravity() as String)
	state_manager.physics_process(delta)

func gather_input():
	move_left_input = Input.is_action_pressed("move_left") as int * -1
	move_right_input = Input.is_action_pressed("move_right") as int
	move_direction =  sign(move_left_input + move_right_input)
	jump_pressed = Input.is_action_just_pressed("jump")
	attack_pressed = Input.is_action_just_pressed("attack")
	
	if jump_pressed:
		jump_buffer.start()
	
	if jump_pressed and Input.is_action_pressed("jump") and is_on_floor():
		is_jump_button_held = true
	
	if is_jump_button_held and not Input.is_action_pressed("jump"):
		is_jump_button_held = false

func apply_gravity(delta):
	if velocity.y <= gravity_max_speed:
		velocity.y += get_gravity() * delta

func get_gravity():
	var modifier = jump_held_modifier if is_jump_button_held else 1.0
	return jump_gravity * modifier if velocity.y < 0.0 else fall_gravity

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
			orientation.scale.x = 1.0
		-1:
			orientation.scale.x = -1.0

func apply_velocity():
	velocity = move_and_slide(velocity + applied_force, Vector2.UP)


func attack():
	var attack_direction = sign(orientation.scale.x)
	
	velocity = Vector2.ZERO
	velocity.x = attack_speed * attack_direction
	
	attack_timer.start()
