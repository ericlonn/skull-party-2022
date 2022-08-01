extends Ammo

onready var sprite: Sprite = $Sprite
onready var destroy_particles: Particles2D = $DestroyedParticles
onready var collision_shape := $CollisionShape2D
onready var animation_player := $AnimationPlayer

var attack_force = Vector2(750,-750)
var x_velocity = 1000
var y_velocity = -400

var rng := RandomNumberGenerator.new()

func _ready():
	if color is Color:
		set_color()
	scale.x *= firing_direction
	set_as_toplevel(true)
	
	apply_central_impulse(Vector2(x_velocity * firing_direction, y_velocity))
	angular_velocity *= firing_direction


func set_color():
	var player_color_as_plane: Plane = Plane(color.r, color.g, color.b, color.a)
	sprite.material.set_shader_param("outline_colour", player_color_as_plane)
	destroy_particles.process_material.color = color

func explode():
	collision_shape.set_deferred("disabled", true)
	set_deferred("mode", RigidBody2D.MODE_STATIC)
	
	animation_player.play("explode")
	

func spawn_destroy_particles():
		var particle_x_dir = abs(destroy_particles.process_material.direction.x)
		particle_x_dir *= firing_direction
		destroy_particles.process_material.direction.x = particle_x_dir
		remove_child(destroy_particles)
		get_node("/root").add_child(destroy_particles)
		destroy_particles.global_position = global_position
		destroy_particles.emitting = true


func _on_Timer_timeout():
	explode()


