extends Node2D

export var sprite_path: NodePath
export var x_orientation_path: NodePath
export var enabled = false setget set_enabled
export var spawn_time = .02
export var fade_time = 0.4
export var SpriteEchoScene: Resource
export var echo_gradient: Gradient

onready var spawn_timer = spawn_time

func set_enabled(value):
	enabled = value

func _process(delta):
		spawn_timer -= delta
		
		if spawn_timer <= 0:
			if enabled:
				spawn_new_echo()
			spawn_timer = spawn_time

func spawn_new_echo():
	if sprite_path.is_empty() or x_orientation_path.is_empty():
		return
	
	var sprite_source = get_node(sprite_path)
	var x_orientation_source = get_node(x_orientation_path)
	
	if not sprite_source is Sprite:
		return
	
	var new_echo = SpriteEchoScene.instance()
	
	if get_parent() is Player:
		var player_color = Rules.get_player_color(get_parent().id)
		for i in echo_gradient.get_point_count():
			new_echo.begin_color = player_color
			new_echo.end_color = player_color - Color(0,0,0,1)
			new_echo.end_color = player_color - Color(0,0,0,1)
	else:
		new_echo.color_gradient = echo_gradient
	
	new_echo.spawn_position = sprite_source.global_position
	new_echo.offset = sprite_source.offset
	new_echo.texture = sprite_source.texture
	new_echo.normal_map = sprite_source.normal_map
	
	new_echo.hframes = sprite_source.hframes
	new_echo.vframes = sprite_source.vframes
	new_echo.frame = sprite_source.frame
	new_echo.scale = sprite_source.scale
	new_echo.scale.x *= sign(x_orientation_source.scale.x)
	
	new_echo.fade_time = fade_time
	
	add_child(new_echo)
	

