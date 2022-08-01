extends Ammo

onready var line: Line2D = $Line2D
onready var destroy_particles: Particles2D = $DestroyedParticles

onready var rng := RandomNumberGenerator.new()

var attack_force = Vector2(750,-750)
var move_speed = 1500

var random_angle = 20


func _ready():
	rng.randomize()
	
	var random_rotation = rng.randf_range(-random_angle, random_angle)
	random_rotation = deg2rad(random_rotation)
	rotate(random_rotation)
	
	if color is Color:
		set_color()
	scale.x *= firing_direction
	set_as_toplevel(true)

func _physics_process(delta):
	var rotated_direction = Vector2.RIGHT.rotated(rotation)
	translate(rotated_direction * move_speed * firing_direction * delta)

func set_color():
	line.default_color = color
	destroy_particles.process_material.color = color


func _on_Area2D_body_entered(body):
	if body is Player:
		body.health -= 1
		body.attacked(global_position, attack_force)
		spawn_destroy_particles()
		queue_free()
	elif body.is_in_group("level"):
		spawn_destroy_particles()
		queue_free()
	elif body.is_in_group("chests"):
		body.attacked(firing_direction, player)
		spawn_destroy_particles()
		queue_free()


func spawn_destroy_particles():
		var particle_x_dir = abs(destroy_particles.process_material.direction.x)
		particle_x_dir *= firing_direction
		destroy_particles.process_material.direction.x = particle_x_dir
		remove_child(destroy_particles)
		get_node("/root").add_child(destroy_particles)
		destroy_particles.global_position = global_position
		destroy_particles.emitting = true




func _on_LifeTimer_timeout():
	spawn_destroy_particles()
	queue_free()
