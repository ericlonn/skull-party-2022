extends KinematicBody2D

signal chested_destroyed(position)

export(PackedScene) var shatter_particles_scene

var velocity = Vector2.ZERO
var sliding_speed = Vector2(2500, 0)
var is_sliding = false

var attack_force = Vector2(1000,-1000)

func _physics_process(delta):
	move_and_collide(velocity * delta)

func _on_OverlapDetector_area_entered(area):
	if is_sliding == false:
		if area.is_in_group("attack_box"):
			var slide_direction = sign(global_position.x - area.global_position.x)
			sliding_speed.x *= slide_direction
			velocity += Vector2(sliding_speed)
			is_sliding = true
	else:
		if area.get_parent().is_in_group("players"):
			area.get_parent().attacked(global_position, attack_force)
			
			var shatter_particles = shatter_particles_scene.instance()
			shatter_particles.global_position = global_position
			get_parent().add_child(shatter_particles)
			
			queue_free()
