extends KinematicBody2D
class_name Chest

signal chested_destroyed(position)

onready var shatter_particles: Particles2D = $ChestDestroyedParticles
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var particles_left: Particles2D = $Particles2DLeft
onready var particles_right: Particles2D = $Particles2DRight
onready var area2d: Area2D = $Area2D

var velocity = Vector2.ZERO
var gravity = 1300
var sliding_speed = Vector2(1300, 0)
var attacked_by
var is_sliding = false

var attack_force = Vector2(1000,-700)

func _ready():
	Events.emit_signal("chest_spawned", self)

func _physics_process(delta):
	if is_sliding == false:
		apply_gravity(delta)
	
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		handle_collision(collision)



func handle_collision(collision):
	var collider = collision.collider
	
	if is_sliding:
		var is_shatter_collision = collider.is_in_group("players") or \
		collider.is_in_group("level")
		
		var is_collision_the_floor = collision.normal == Vector2(0,-1)
		var is_collision_ahead = sign(velocity.x) != sign(collision.normal.x)
		if is_shatter_collision and is_collision_ahead and not is_collision_the_floor:
			shatter(collider)
			
	elif not is_sliding and collision != null:
		if collider.is_in_group("chests"):
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
	
	Events.emit_signal("chest_shattered", self)
	queue_free()

func apply_gravity(delta):
	velocity.y += gravity * delta

func attacked(attack_direction, attacker= null):
	if is_sliding:
		return
	
	attacked_by = attacker
	
	var slide_direction = sign(attack_direction)
	sliding_speed.x *= slide_direction
	velocity += Vector2(sliding_speed)
	velocity.y = 0
	is_sliding = true
	
	var particle_color
	if attacked_by != null:
		particle_color = Rules.get_player_color(attacked_by.id)
	else:
		particle_color = Color.white
	
	if sliding_speed.x > 0:
		particles_left.emitting = true
		particles_left.process_material.color = particle_color
	else:
		particles_right.emitting = true
		particles_right.process_material.color = particle_color
	shatter_particles.process_material.color = particle_color
	
	
	# make sure the attacking player doesn't get hit
	if not area2d.get_overlapping_bodies().has(attacked_by):
		set_collision_mask_bit(0, true)


func _on_Area2D_body_exited(body):
	# once the attacking player isn't overlapping, they can be hit.
	# not sure when this will come up but who knows
	if is_sliding:
		if body == attacked_by:
			set_collision_mask_bit(0, true)
			attacked_by = null
