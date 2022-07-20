class_name Player
extends KinematicBody2D

onready var debug_label: Label = $DebugLabel
onready var sprite: Sprite = $Orientation/Sprite
onready var sprite_echo_generator: Node2D = $SpriteEchoGenerator
onready var animator: AnimationPlayer = $Orientation/Sprite/AnimationPlayer
onready var state_manager = $State_Manager

onready var jump_buffer: Timer = $JumpBuffer
onready var attack_timer: Timer = $AttackTimer
onready var stun_timer: Timer = $StunTimer
onready var coyote_timer: Timer = $CoyoteTimer

onready var orientation: Node2D = $Orientation
onready var punch: Area2D = $Orientation/Punch
onready var debug_line: Line2D = $DebugLine
onready var collision_detector: Area2D = $CollisionDetector
onready var slide_particles: Particles2D = $Orientation/SlideParticles
onready var right_wall_check = $RightWallCheck
onready var left_wall_check = $LeftWallCheck

onready var rng = RandomNumberGenerator.new()

var velocity = Vector2.ZERO

var gravity = 3000.0
var gravity_max_speed = 1800.0

var move_speed = 1000.0
var move_accel = 3500.0
var move_max_speed = 6000.0
var slow_down_speed = 5000.0

var jump_force = 1200.00
var air_control_speed = 6000.0

var move_left_input = 0
var move_right_input = 0
var move_direction = 0

var was_on_floor = false
var is_wall_on_left setget , get_is_wall_on_left
var is_wall_on_right setget , get_is_wall_on_right

var attack_speed = 2200.0
var bonk_speed = Vector2(600.0, -675.0)

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
export(PackedScene) var powerskull_scene

var wall_jump_x_force = 1200.0
var wall_jump_x_move_reduction_direction = 0
var wall_jump_x_move_reduction_length= 0.2
onready var wall_jump_x_move_reduction_timer = wall_jump_x_move_reduction_length

onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var id: int
var powerskulls = []



func _ready():
	rng.randomize()
	state_manager.init(self)

func _process(delta):
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
		move_left_input = Input.is_action_pressed("move_left") as int * -1
		move_right_input = Input.is_action_pressed("move_right") as int
		move_direction =  sign(move_left_input + move_right_input)
		jump_pressed = Input.is_action_just_pressed("jump")
		attack_pressed = Input.is_action_just_pressed("attack")
		
		if jump_pressed:
			jump_buffer.start()
		
		if jump_pressed and is_on_floor():
			is_jump_button_held = true
		
		if is_jump_button_held and not Input.is_action_pressed("jump"):
			is_jump_button_held = false

func apply_gravity(delta, wall_slide: bool = false):
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
	
	velocity.y = jump_velocity

func apply_x_movement(delta):
	if is_on_floor():
		if move_direction != 0:
			velocity.x = move_toward(velocity.x, move_speed * move_direction, move_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, move_speed * move_direction, slow_down_speed * delta)
	else:
		if move_direction != 0 and move_direction != wall_jump_x_move_reduction_direction:
			velocity.x = move_toward(velocity.x, move_speed * move_direction, air_control_speed * delta)
	
func orient_character():
	match move_direction:
		1:
			orientation.face_right()
		-1:
			orientation.face_left()


func flip_orientation():
	orientation.scale.x = -orientation.scale.x


func apply_velocity():
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)


func attack():
	var attack_direction = sign(orientation.scale.x)
	
	velocity = Vector2.ZERO
	velocity.x = attack_speed * attack_direction
	
	attack_timer.start()


func attacked(attack_direction: Vector2, attack_force: Vector2):
	var knockback_x_direction = sign(position.x - attack_direction.x)
	
	
	knockback_x_direction = knockback_x_direction if knockback_x_direction != 0 else round(rng.randf_range(-1, 1))
	
	velocity.x =  attack_force.x * knockback_x_direction
	velocity.y = attack_force.y
	stun_triggered = true
	
	lose_powerskull()
	


func bonk(bonked_from_position: Vector2):
	var bonk_vector = position - bonked_from_position
	var bonk_x_dir = sign(bonk_vector.x)
	velocity.x =  bonk_speed.x * bonk_x_dir
	velocity.y = bonk_speed.y


func _on_CollisionDetector_body_entered(body):
	if body.get_collision_layer() == 1 and body != self:
		bonk(body.position)

func get_is_wall_on_left():
	return left_wall_check.is_colliding()

func get_is_wall_on_right():
	return right_wall_check.is_colliding()

func add_powerskull(powerskull_type: int):
	if powerskulls.size() < 3:
		powerskulls.append(powerskull_type)
		Events.emit_signal("skull_count_updated", self, powerskulls)
	

func lose_powerskull():
		if powerskulls.size() > 0:
			var remove_from_front = true if rng.randi_range(0, 1) == 0 else false
			var removed_skull
			if remove_from_front:
				removed_skull = powerskulls.pop_front()
			else:
				removed_skull = powerskulls.pop_back()
			
			Events.emit_signal("skull_lost", self, removed_skull)
			Events.emit_signal("skull_count_updated", self, powerskulls)
