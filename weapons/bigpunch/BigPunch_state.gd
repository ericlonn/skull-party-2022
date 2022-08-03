extends BaseState

onready var super_weapon = get_parent()
onready var punch_timer: Timer = $PunchTimer

var attack_connected = false
var attack_force = Vector2(750,-750)
var attack_direction = 0

var x_move_margin_pixel = 32

func enter():
	player = super_weapon.player
	
	attack_direction = sign(player.orientation.scale.x)
	
	player.velocity = Vector2.ZERO
	player.velocity.x = super_weapon.punch_speed * attack_direction

	punch_timer.start()
	
	player.play_animation("punch")
	player.sprite_echo_generator.enabled = true
	
	super_weapon.activate()


func physics_process(delta):
	if punch_timer.time_left == 0:
		print("DONE")
		return State.Idle
	
	ledge_punch_correction()
#	player.apply_gravity()
#	player.apply_x_movement()
#	player.orient_character()
	player.apply_velocity()
	
	return State.Null

func ledge_punch_correction():
	var delta = get_physics_process_delta_time()
	var next_x_step = Vector2(player.velocity.x * delta, 0)
	
	if player.test_move(player.global_transform, next_x_step):
		for i in x_move_margin_pixel:
			for j in [-1, 1]:
				var test_transform = player.global_transform.translated(Vector2(0, (i*j)))
				if !player.test_move(test_transform, next_x_step):
					var new_translate = Vector2(0, (i*j))
					player.translate(new_translate)
					return


func exit():
	player.sprite_echo_generator.enabled = false
	super_weapon.deactivate()
