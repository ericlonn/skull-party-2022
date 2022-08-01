extends BaseState

onready var death_animator := $DeathAnimator

func enter():
	player.animator.play("death")
	death_animator.play("death")
	

func physics_process(delta):
	player.apply_gravity()
	player.apply_velocity()
	return State.Null


func emit_death_signal():
	Events.emit_signal("player_died", player, Rules.get_player_color(player.id), player.global_position)
