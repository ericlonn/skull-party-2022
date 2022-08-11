extends BaseState

onready var punch_timer: Timer = $PunchTimer

var attack_connected = false
var attack_force = Vector2(750,-750)
var attack_direction = 0

var x_move_margin_pixel = 32

var punch_speed = 1200.0

func enter():
	attack_direction = sign(player.orientation.scale.x)

	player.movement.velocity = Vector2.ZERO
	player.movement.velocity.x = punch_speed * attack_direction

	punch_timer.start()
	
	player.punch.monitoring = true
	player.punch.monitorable = true
	player.punch.visible = true
	player.visuals.play_animation("punch")
	
	player.visuals.sprite_echo_generator.enabled = true

func process(delta: float):
	if player.is_dead:
		return State.Dead
	
	if punch_timer.time_left <= 0:
		return State.Idle
	
	if attack_connected:
		Fmod.play_one_shot("event:/Player/Punch Landing", self)
		player.hit_stop()
		attack_connected = false
		return State.Run
	
	return State.Null


func physics_process(delta):
	ledge_punch_correction()
#	player.apply_gravity()
#	player.apply_x_movement()
#	player.orient_character()
	player.movement.apply_velocity()
	
	return State.Null


func exit():
	player.punch.monitoring = false
	player.punch.monitorable = false
	player.punch.visible = false
	player.visuals.sprite_echo_generator.enabled = false
	player.attack_limit_timer.start()


func ledge_punch_correction():
	var delta = get_physics_process_delta_time()
	var next_x_step = Vector2(player.movement.velocity.x * delta, 0)
	
	if player.test_move(player.global_transform, next_x_step):
		for i in x_move_margin_pixel:
			for j in [-1, 1]:
				var test_transform = player.global_transform.translated(Vector2(0, (i*j)))
				if !player.test_move(test_transform, next_x_step):
					var new_translate = Vector2(0, (i*j))
					player.translate(new_translate)
					return


func _on_Punch_body_entered(body):
	print(body.name)
	if body != player and body is Player:
		body.attacked(player.position, attack_force)
		player.movement.bonk(body.position)
		attack_connected = true
	elif body.is_in_group("level"):
		player.movement.bonk(player.position + Vector2.RIGHT * attack_direction )
		attack_connected = true
	elif body is Chest:
		body.attacked(player.movement.velocity.x, player)
		player.movement.bonk(player.position + Vector2.RIGHT * attack_direction )
		attack_connected = true
