extends Camera2D

export var move_speed = 0.5  # camera position lerp speed
export var zoom_speed = 0.25  # camera zoom lerp speed
export var min_zoom = 1.5  # camera won't zoom closer than this
export var max_zoom = 5  # camera won't zoom farther than this
export var margin = Vector2(400, 200)  # include some buffer area around targets

var targets = []  # Array of targets to be tracked.

var placeholder_lifetime = 1

onready var screen_size = get_viewport_rect().size
onready var camera_shake := $CameraShake

func _ready():
	Events.connect("skull_spawned", self, "on_skull_spawned")
	Events.connect("skull_collected", self, "on_skull_collected")
	Events.connect("chest_spawned", self, "on_chest_spawned")
	Events.connect("chest_shattered", self, "on_chest_shattered")
	Events.connect("player_died", self, "on_Player_died")

func _process(delta):
	if !targets:
		return

	# Keep the camera centered between the targets
	var p = Vector2.ZERO
#	for target in targets:
#		p += target.position
#	p /= targets.size()
#	position = lerp(position, p, move_speed)

	# Find the zoom that will contain all targets
	var r = Rect2(position, Vector2.ONE)
	for target in targets:
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	var d = max(r.size.x, r.size.y)
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = clamp(r.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		z = clamp(r.size.y / screen_size.y, min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed)
	position = r.position + r.size / 2

func add_target(t):
	if not t in targets:
		targets.append(t)

func remove_target(t):
	if targets.has(t):
		targets.erase(t)


func on_Player_died(player, color, death_position):
	remove_target(player)
	add_delay_placeholder(death_position)


func add_delay_placeholder(pos: Vector2):
	var placeholder_pos := Node2D.new()
	placeholder_pos.global_position = pos
	add_child(placeholder_pos)
	
	var life_timer := Timer.new()
	life_timer.wait_time = placeholder_lifetime
	life_timer.one_shot = true
	placeholder_pos.add_child(life_timer)
	
	add_target(placeholder_pos)
	life_timer.start()
	
	yield(life_timer,"timeout")
	
	remove_target(placeholder_pos)
	placeholder_pos.queue_free()


func shake(duration: float = -1.0):
	if duration == -1.0:
		camera_shake.shake()
	else:
		camera_shake.shake(duration)


func remove_invalid_instances():
	for target in targets:
		if not is_instance_valid(target):
			targets.erase(target)
