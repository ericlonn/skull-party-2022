extends Ammo_kinematic

onready var destroy_particles: Particles2D = $DestroyedParticles
onready var blade_sprite := $Sawblade
onready var overlap_detector := $Area2D

export(PackedScene) var bounce_particles

var attack_force = Vector2(750,-750)
var move_speed = 1200

var velocity := Vector2.ZERO
var rotation_speed := 360 * 3

var firing_angle = deg2rad(45)
var firing_angle_variation = deg2rad(5)

func _ready():
	if color is Color:
		set_color()
	scale.x *= firing_direction
	set_as_toplevel(true)
	
	var init_angle: Vector2 = Vector2.RIGHT * firing_direction * move_speed
	init_angle = init_angle.rotated(firing_angle)
	
	var rand_angle_variation = Globals.rng.randf_range(-firing_angle_variation, firing_angle_variation)
	init_angle = init_angle.rotated(rand_angle_variation)
	
	var up_or_down = [-1,1][Globals.rng.randi_range(0, 1)]
	init_angle.y *= up_or_down
	
	velocity = init_angle


func _process(delta):
	if velocity.x > 0:
		rotation_degrees += rotation_speed * delta
	else:
		rotation_degrees -= rotation_speed * delta


func _physics_process(delta):
	if not overlap_detector.get_overlapping_bodies().has(player):
		set_collision_mask_bit(0, true)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		
		var new_bounce_part = bounce_particles.instance()
		new_bounce_part.global_position = collision.position
		new_bounce_part.rotation = collision.normal.angle()
		
		get_tree().root.add_child(new_bounce_part)
		
		Fmod.play_one_shot("event:/Weapons/SawRicochet", self)

func set_color():
	destroy_particles.process_material.color = color
	blade_sprite.modulate = color


func _on_Area2D_body_entered(body):
	if body is Player and not body.is_stunned:
		body.attacked(global_position, attack_force, 1)
		spawn_destroy_particles()
		queue_free()
#	elif body.is_in_group("level"):
#		spawn_destroy_particles()
#		queue_free()
	elif body is Chest:
		body.attacked(firing_direction, player)
		spawn_destroy_particles()
		queue_free()


func spawn_destroy_particles():
		remove_child(destroy_particles)
		get_node("/root").add_child(destroy_particles)
		destroy_particles.global_position = global_position
		destroy_particles.emitting = true
