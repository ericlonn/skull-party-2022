extends Ammo

onready var destroy_particles: Particles2D = $DestroyedParticles

var attack_force = Vector2(750,-750)
var move_speed = 500
var pathfinder
var current_path: PoolVector2Array

var bez_ratio = 0.2

func _ready():
	if color is Color:
		set_color()
	
	scale.x *= firing_direction


func _physics_process(delta):
	pass


func set_color():
	pass


#func _on_Area2D_body_entered(body):
#	if body is Player and not body.is_stunned:
#		body.attacked(global_position, attack_force, 1)
#		spawn_destroy_particles()
#		queue_free()
#	elif body.is_in_group("level"):
#		spawn_destroy_particles()
#		queue_free()
#	elif body is Chest:
#		body.attacked(firing_direction, player)
#		spawn_destroy_particles()
#		queue_free()


func spawn_destroy_particles():
		var particle_x_dir = abs(destroy_particles.process_material.direction.x)
		particle_x_dir *= firing_direction
		destroy_particles.process_material.direction.x = particle_x_dir
		remove_child(destroy_particles)
		get_node("/root").add_child(destroy_particles)
		destroy_particles.global_position = global_position
		destroy_particles.emitting = true
