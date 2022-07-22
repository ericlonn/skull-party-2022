extends KinematicBody2D
class_name Chest

signal chested_destroyed(position)

onready var shatter_particles: Particles2D = $ChestDestroyedParticles
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var sprite_echo_generator = $SpriteEchoGenerator

var velocity = Vector2.ZERO
var gravity = 1300
var sliding_speed = Vector2(1000, 0)
var is_sliding = false

var attack_force = Vector2(1000,-1500)

func _physics_process(delta):
	if is_sliding == false:
		apply_gravity(delta)
	
	var collision = move_and_collide(velocity * delta)
	if is_sliding and collision != null:
		var collider = collision.collider
		var is_shatter_collision = collider.is_in_group("players") or collider.is_in_group("level")
		var is_collision_the_floor = collision.normal == Vector2(0,-1)
		if is_shatter_collision and not is_collision_the_floor:
			shatter(collider)
	
func shatter(collider):
	if collider.is_in_group("players"):
		collider.attacked(global_position, attack_force)
	
	shatter_particles.process_material.direction.x *= sign(velocity.x)
	
	var particle_x_offset = collision_shape.shape.extents.x * sign(velocity.x)
	shatter_particles.position.x = particle_x_offset
	
	remove_child(shatter_particles)
	get_parent().add_child(shatter_particles)
	shatter_particles.position += global_position
	shatter_particles.emitting = true
	
	queue_free()

func apply_gravity(delta):
	velocity.y += gravity * delta

func attacked(attacked_from_pos):
	if is_sliding:
		return
	
	var slide_direction = sign(global_position.x - attacked_from_pos.x)
	sliding_speed.x *= slide_direction
	velocity += Vector2(sliding_speed)
	is_sliding = true
	velocity.y = 0
	set_collision_layer_bit(0, true)
