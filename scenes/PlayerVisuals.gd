extends Node

onready var player = owner

onready var debug_label: Label = $"%DebugLabel"
onready var debug_line: Line2D = $"%DebugLine"

onready var sprite: Sprite = $"%Sprite"
onready var sprite_echo_generator: Node2D = $"%SpriteEchoGenerator"
onready var animator: AnimationPlayer = $"%AnimationPlayer"

onready var slide_particles: Particles2D = $"%SlideParticles"
onready var powerup_visuals = $"%PowerUpVisuals"
onready var death_visuals := $"%DeathVisuals"

onready var squash_stretch := $"%SquashStretch"


func _ready():
	Events.connect("player_id_assigned", self, "on_player_id_assigned")

func set_child_colors(id: int):
	var color = Globals.get_player_color(id)
	var player_color_as_plane: Plane = Plane(color.r, color.g, color.b, color.a)
	
	sprite.material.set_shader_param("outline_colour", player_color_as_plane)
	
	powerup_visuals.set_color(color)
	death_visuals.set_color(color)
	
	sprite_echo_generator.set_color(color)
	
	slide_particles.process_material.color = color


func on_player_id_assigned(player_signalled):
	print(player_signalled.id as String)
	if player_signalled == player:
		set_child_colors(player.id)


func play_animation(animation_name: String):
	if player.is_in_hit_stop:
		yield(player.hit_stop_timer, "timeout")
	
	animator.play(animation_name)


func squash():
	squash_stretch.squash()


func stretch():
	squash_stretch.stretch()
