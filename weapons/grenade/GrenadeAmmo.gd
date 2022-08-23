extends Ammo_rigid

onready var sprite: Sprite = $Sprite
onready var destroy_particles: Particles2D = $DestroyedParticles
onready var collision_shape := $CollisionShape2D
onready var overlap_detector := $OverlapDetector

onready var explosion_hitbox := $Explosion/ExplosionHitBox
onready var explosion_animplayer := $Explosion/ExplosionAnimPlayer
onready var explosion_sprite := $Explosion/ExplosionsSprite
onready var level_collision_check := $Explosion/LevelCollisionCheck

var attack_force = Vector2(2000, -2000)
var x_velocity = 1000
var y_velocity = -400

var has_bounced =false

var rng := Globals.rng


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
	Fmod.play_one_shot("event:/Weapons/GrenadeExplosion", self)
	
	for body in explosion_hitbox.get_overlapping_bodies():
		level_collision_check.cast_to = to_local(body.position)
		level_collision_check.force_raycast_update()
		if level_collision_check.is_colliding():
			continue
		
		if body is Player:
			body.attacked(global_position, attack_force, 1)
		elif body is Chest:
			body.attacked(body.global_position.x - global_position.x, player)
		elif body is Powerskull:
			var applied_force = Vector2.ZERO
			applied_force.x = sign(body.position.x - global_position.x)
			applied_force.y = -sign(body.position.y - global_position.y)
			applied_force = applied_force * attack_force
			body.apply_force(applied_force)
			
	

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


func _on_GrenadeAmmo_body_entered(body):
	if not has_bounced and body == player:
		pass
	else:
		play_bounce_audio()
		has_bounced = true
	
func play_bounce_audio():
	Fmod.play_one_shot("event:/Weapons/GrenadeBounce", self)
