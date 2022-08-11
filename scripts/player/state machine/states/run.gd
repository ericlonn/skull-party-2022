extends BaseState

var running_sfx_event
var sliding_sfx_event

func enter():
	running_sfx_event = Fmod.create_event_instance("event:/Player/Run")
	sliding_sfx_event = Fmod.create_event_instance("event:/Player/Slide")
	
	Fmod.start_event(running_sfx_event)
	Fmod.start_event(sliding_sfx_event)
	Fmod.set_event_paused(sliding_sfx_event, true)
	
	player.visuals.play_animation("run")

func process(delta: float):
	if player.is_dead:
		return State.Dead
	
	if player.stun_triggered:
		return State.Stunned
	
	if player.input.jump_pressed:
		return State.Jump
	
	if player.input.attack_pressed:
		return State.Attack
	
	if player.input.move_direction == 0:
		return State.Idle
	
	if not player.is_on_floor():
		player.coyote_timer.start()
		return State.Fall
	
	return State.Null

func physics_process(delta: float):
	player.movement.apply_gravity()
	
	player.movement.apply_x_movement()
	player.orientation.orient_character()
	player.movement.apply_velocity()
	
	choose_animation()
	
	return State.Null
	
func choose_animation():
	if player.input.move_direction != sign(player.movement.velocity.x) and abs(player.movement.velocity.x) > 0.0:
		if not Fmod.get_event_paused(running_sfx_event):
			Fmod.set_event_paused(running_sfx_event, true)
		
		player.visuals.play_animation("slide")
		player.visuals.slide_particles.emitting = true
	else:
		if Fmod.get_event_paused(running_sfx_event):
			Fmod.set_event_paused(running_sfx_event, false)
		
		player.visuals.play_animation("run")
		player.visuals.slide_particles.emitting = false

func exit():
	Fmod.stop_event(running_sfx_event, Fmod.FMOD_STUDIO_STOP_IMMEDIATE)
	player.visuals.slide_particles.emitting = false
