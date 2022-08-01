extends BaseState

onready var punch_timer: Timer = $PunchTimer

var attack_connected = false
var attack_force = Vector2(750,-750)
var attack_direction = 0

var x_move_margin_pixel = 32

var punch_speed = 1200.0

func enter():
	attack_direction = sign(player.orientation.scale.x)

	player.velocity = Vector2.ZERO
	player.velocity.x = punch_speed * attack_direction

	punch_timer.start()
	
	player.punch.monitoring = true
	player.punch.monitorable = true
	player.punch.visible = true
	player.animator.play("punch")
	
	player.sprite_echo_generator.enabled = true

func process(delta: float):
	if punch_timer.time_left <= 0:
		return State.Idle
	
	if attack_connected:
		attack_connected = false
		return State.Run
	
	return State.Null


func physics_process(delta):
	ledge_punch_correction()
#	player.apply_gravity()
#	player.apply_x_movement()
#	player.orient_character()
	player.apply_velocity()
	
	return State.Null


func exit():
	player.punch.monitoring = false
	player.punch.monitorable = false
	player.punch.visible = false
	player.sprite_echo_generator.enabled = false
	player.attack_limit_timer.start()


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


func _on_Punch_body_entered(body):
	if body != player and body is Player:
		body.attacked(player.position, attack_force)
		player.bonk(body.position)
		attack_connected = true
	elif body.is_in_group("level"):
		player.bonk(player.position + Vector2.RIGHT * attack_direction )
		attack_connected = true
	elif body is Chest:
		body.attacked(player.velocity.x, player)
		player.bonk(player.position + Vector2.RIGHT * attack_direction )
		attack_connected = true