extends BaseState

onready var death_animator := $DeathAnimator

var death_visuals: Node2D
var death_particles: Particles2D

var initial_orientation_pos
var vibrate_start_amplitude = Vector2(0,0)
var vibrate_end_amplitude = Vector2(20,10)
var vibrate_time = 0.0

func enter():
	death_visuals = player.death_visuals
	death_particles = death_visuals.death_particles
	
	initial_orientation_pos = player.orientation.position
	
	player.play_animation("death")
	death_animator.play("death")


func physics_process(delta):
	vibrate()
	player.translate(Vector2(0, -30) * delta)
	return State.Null


func emit_death_begun_signal():
	Events.emit_signal("player_death_begun", player)
	
	death_particles.global_position = player.global_position
	death_particles.emitting = true


func emit_death_complete_signal():
	Events.emit_signal("player_died", player, Globals.get_player_color(player.id), player.global_position)


func spawn_death_particles():
	death_visuals.remove_child(death_particles)
	get_tree().get_root().add_child(death_particles)


func vibrate():
	var anim_length = death_animator.get_animation("death").length
	var anim_progress = vibrate_time / anim_length
	
	var amplitude_distance = vibrate_end_amplitude - vibrate_start_amplitude
	var vibration_vector = vibrate_start_amplitude + amplitude_distance * anim_progress
	vibration_vector.x = Globals.rng.randf_range(-vibration_vector.x, vibration_vector.x)
	vibration_vector.y = Globals.rng.randf_range(-vibration_vector.y, vibration_vector.y)

	print(str(vibration_vector))
	
	player.orientation.position = initial_orientation_pos + vibration_vector
	
	vibrate_time += get_process_delta_time()

