extends Node

onready var player = owner

var move_left_input = 0
var move_right_input = 0
var move_direction = 0

var jump_pressed = false
var is_jump_button_held = false
var attack_pressed = false

func _process(delta):
	var id = player.id
	
	if player.enabled:
		move_left_input = Input.is_action_pressed("move_left" + str(id)) as int * -1
		move_right_input = Input.is_action_pressed("move_right" + str(id)) as int
		move_direction =  sign(move_left_input + move_right_input)
		jump_pressed = Input.is_action_just_pressed("jump" + str(id))
		attack_pressed = Input.is_action_just_pressed("attack" + str(id))

		if jump_pressed:
			player.jump_buffer.start()

		if jump_pressed and player.is_on_floor():
			is_jump_button_held = true

		if is_jump_button_held and not Input.is_action_pressed("jump" + str(id)):
			is_jump_button_held = false
