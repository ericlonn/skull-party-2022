extends BaseState

onready var death_animator := $DeathAnimator
onready var death_particles := $DeathParticles

func enter():
	player.play_animation("death")
	death_animator.play("death")
	

func physics_process(delta):
	player.translate(Vector2(0, -30) * delta)
	return State.Null


func emit_death_begun_signal():
	Events.emit_signal("player_death_begun", player)


func emit_death_complete_signal():
	Events.emit_signal("player_died", player, Globals.get_player_color(player.id), player.global_position)


func spawn_death_particles():
	remove_child(death_particles)
	get_tree().get_root().add_child(death_particles)
	death_particles.global_position = player.global_position
	death_particles.emitting = true
