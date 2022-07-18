extends Node2D

export var enabled = false setget set_enabled
export var spawn_time = .02
export var fade_time = 0.4
export var SpriteEchoScene: Resource

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
	var new_echo = SpriteEchoScene.instance()
	var player: Player = get_parent()
	
	new_echo.spawn_position = player.sprite.global_position
	new_echo.texture = player.sprite.texture
	new_echo.normal_map = player.sprite.normal_map
	new_echo.hframes = player.sprite.hframes
	new_echo.vframes = player.sprite.vframes
	new_echo.frame = player.sprite.frame
	new_echo.scale = player.sprite.scale
	new_echo.scale.x *= player.orientation.scale.x
	
	new_echo.fade_time = fade_time
	
	add_child(new_echo)
	
	
