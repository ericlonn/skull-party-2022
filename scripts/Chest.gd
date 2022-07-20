extends KinematicBody2D

signal chested_destroyed(position)

export(PackedScene) var shatter_particles_scene

var velocity = Vector2.ZERO
var gravity = 1300
var sliding_speed = Vector2(2500, 0)
var is_sliding = false

var attack_force = Vector2(1000,-1000)

func _physics_process(delta):
	if is_sliding == false:
		apply_gravity(delta)
	
	var collision = move_and_collide(velocity * delta)
	
	if is_sliding and collision != null:
		var collider = collision.collider
		var is_shatter_collision = collider.is_in_group("players") or collider.is_in_group("level")
		if is_shatter_collision:
			shatter(collider)
	
func shatter(collider):
	print("shatter")
	if collider is Player:
		collider.attacked(global_position, attack_force)
			
	var shatter_particles: Particles2D = shatter_particles_scene.instance()
	shatter_particles.process_material.direction.x *= sign(velocity.x)
	shatter_particles.global_position = global_position
	get_parent().add_child(shatter_particles)
	shatter_particles.emitting = true
	
	queue_free()


func apply_gravity(delta):
	velocity.y += gravity * delta

func _on_OverlapDetector_area_entered(area):
	if is_sliding == false:
		if area.is_in_group("attack_box"):
			var slide_direction = sign(global_position.x - area.global_position.x)
			sliding_speed.x *= slide_direction
			velocity += Vector2(sliding_speed)
			is_sliding = true
			velocity.y = 0
			set_collision_layer_bit(0, true)
