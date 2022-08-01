extends Ammo

onready var sprite: Sprite = $Sprite
onready var destroy_particles: Particles2D = $DestroyedParticles
onready var collision_shape := $CollisionShape2D
onready var overlap_detector := $OverlapDetector

onready var explosion_hitbox := $Explosion/ExplosionHitBox
onready var explosion_animplayer := $Explosion/ExplosionAnimPlayer
onready var explosion_sprite := $Explosion/ExplosionsSprite
onready var level_collision_check := $Explosion/LevelCollisionCheck

var attack_force = Vector2(50000, -50000)
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


func _physics_process(delta):
	if not overlap_detector.get_overlapping_bodies().has(player):
		set_collision_mask_bit(0, true)


func set_color():
	var player_color_as_plane: Plane = Plane(color.r, color.g, color.b, color.a)
	sprite.material.set_shader_param("outline_colour", player_color_as_plane)
	
	explosion_sprite.modulate = color

func explode():
	collision_shape.set_deferred("disabled", true)
	set_deferred("mode", RigidBody2D.MODE_STATIC)
	
	explosion_animplayer.play("explosion")
	
	for body in explosion_hitbox.get_overlapping_bodies():
		if body is Player:
			level_collision_check.cast_to = to_local(body.position)
			level_collision_check.force_raycast_update()
			
			if not level_collision_check.is_colliding():
				body.health -= 1
				body.attacked(global_position, attack_force)
			
	

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
