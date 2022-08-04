extends Node2D


onready var death_particles := $DeathParticles
onready var death_energy := $DeathEnergy


func set_color(player_color: Color):
	death_particles.process_material.color = player_color
	death_energy.modulate = player_color
