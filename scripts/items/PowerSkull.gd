tool
extends RigidBody2D
class_name Powerskull

export(Globals.powerskull_types) var powerskull_type setget set_powerskull_type

var collected = false
var collected_by: Player
var collected_position: Vector2

var manual_position: Vector2

var move_toward_time = .5

onready var tween: Tween = $Tween
onready var sprite: Sprite = $PowerSkull
onready var glow_sprite: Sprite = $Glow
onready var trail: Line2D = $Trail2D
onready var particles: Particles2D = $Particles2D
onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var launch_speed = Vector2(0, -1250)
var launch_random_angle = 45

var skull_to_skull_force = Vector2(500,500)
var random_skull_bounce_angle = 10

func _ready():
	Events.emit_signal("skull_spawned", self)
	set_sprite_color(powerskull_type)

func move_toward_player(t):
	manual_position = collected_position.linear_interpolate(collected_by.global_position, t)
	position = manual_position

func manually_set_position(new_pos: Vector2): 
	mode = RigidBody2D.MODE_STATIC
	global_position = new_pos
	mode = RigidBody2D.MODE_CHARACTER


func _on_OverlapDetector_body_entered(body):
	if body.is_in_group("players") and collected == false:
		if body.powerskulls.size() >= 3:
			return
		elif body.is_stunned:
			return
		
		collected = true
		collected_by = body
		collected_position = global_position
		
		Events.emit_signal("skull_collected", self)
		
		set_collision_layer_bit(2, false)
		set_collision_mask_bit(1, false)
		set_collision_mask_bit(2, false)
		set_collision_mask_bit(3, false)
		
		body.add_powerskull(powerskull_type)
		set_deferred("mode", RigidBody2D.MODE_STATIC)
		
		tween.interpolate_method(self, "move_toward_player", 0.0, 1.0, move_toward_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(self, "scale", scale, Vector2.ZERO, move_toward_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(trail, "width", trail.width, 0, move_toward_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		particles.emitting = false
		tween.start()
		
		yield(tween, "tween_completed")
		queue_free()
	elif body.is_in_group("powerskulls"):
		var norm_vector: Vector2 = (body.global_position - global_position).normalized()
		
		var random_angle_rads = deg2rad(random_skull_bounce_angle)
		random_angle_rads = rng.randf_range(-random_angle_rads, random_angle_rads)
		norm_vector = norm_vector.rotated(random_angle_rads)
		
		apply_central_impulse(-norm_vector * skull_to_skull_force)


func set_powerskull_type(value):
	powerskull_type = value
	set_sprite_color(value)
	

func set_sprite_color(type):
	$PowerSkull.modulate = Globals.get_skull_color(type)
	$Glow.modulate = Globals.get_skull_color(type)
	$Trail2D.default_color = Globals.get_skull_color(type)
	$Light2D.color = Globals.get_skull_color(type)
	$Particles2D.process_material.color = Globals.get_skull_color(type)


func apply_force(force):
	print(str(force))
	apply_central_impulse(force)
	
	
