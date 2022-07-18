tool
extends RigidBody2D

export(Rules.powerskull_types) var powerskull_type setget set_powerskull_type

var collected = false
var collected_by: Player
var collected_position: Vector2

var manual_position: Vector2

var move_toward_time = .5

onready var tween: Tween = $Tween
onready var sprite: Sprite = $PowerSkull
onready var glow_sprite: Sprite = $Glow

func _ready():
	set_sprite_color(powerskull_type)

func move_toward_player(t):
	manual_position = collected_position.linear_interpolate(collected_by.global_position, t)
	position = manual_position
	

func _on_OverlapDetector_body_entered(body):
	if body.is_in_group("players") and collected == false:
		collected = true
		collected_by = body
		collected_position = global_position
		
		body.add_powerskull(powerskull_type)
		mode = RigidBody2D.MODE_STATIC
		
		tween.interpolate_method(self, "move_toward_player", 0.0, 1.0, move_toward_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(self, "scale", scale, Vector2.ZERO, move_toward_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		
		yield(tween, "tween_completed")
		queue_free()

func set_powerskull_type(value):
	powerskull_type = value
	set_sprite_color(value)
	

func set_sprite_color(type):
	match type:
		0:
			$PowerSkull.modulate = Color.red
			$Glow.modulate = Color.red
		1:
			$PowerSkull.modulate = Color.green
			$Glow.modulate = Color.green
		2:
			$PowerSkull.modulate = Color.blue
			$Glow.modulate = Color.blue
