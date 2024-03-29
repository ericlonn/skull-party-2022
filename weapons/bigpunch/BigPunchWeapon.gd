extends SuperWeapon

onready var big_punch_node := $BigPunch
onready var sprite := $BigPunch/BigPunchSprite
onready var area := $BigPunch/Area2D

var punch_speed = 1200.0
var attack_force = Vector2(1750,-1750)

func _ready():
	big_punch_node.position = bullet_spawn_point.position
	sprite.visible = false
	area.monitoring = false
	
	set_color()

func fire():
	pass


func activate():	
	sprite.visible = true
	area.monitoring = true


func deactivate():
	sprite.visible = false
	area.monitoring = false


func set_color():
	var color = Globals.get_player_color(player.id)
	var player_color_as_plane: Plane = Plane(color.r, color.g, color.b, color.a)
	sprite.material.set_shader_param("outline_colour", player_color_as_plane)


func _on_Area2D_body_entered(body):
	var firing_direction = sign(player.orientation.scale.x)
	
	if body is Player and body != player:
		body.attacked(global_position, attack_force, 1)
		Fmod.play_one_shot("event:/Player/Punch Landing", self)
		used_state.attack_connected = true
		player.hit_stop()
	elif body.is_in_group("level"):
		player.movement.velocity.x = punch_speed * -sign(firing_direction)
		Fmod.play_one_shot("event:/Player/Punch Landing", self)
		player.hit_stop()
		player.orientation.flip()
	elif body is Chest:
		body.attacked(firing_direction, player)
