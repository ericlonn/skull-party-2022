class_name Player
extends KinematicBody2D



onready var state_manager := $"%State_Manager"
onready var movement := $"%Movement"
onready var input := $"%Input"
onready var orientation := $"%Orientation"
onready var visuals := $"%Visuals"

onready var stun_timer: Timer = $"%StunTimer"
onready var coyote_timer: Timer = $"%CoyoteTimer"
onready var wall_jump_coyote_timer: Timer = $"%WallJumpCoyoteTimer"
onready var attack_limit_timer: Timer = $"%AttackLimitTimer"
onready var hit_stop_timer: Timer = $"%HitStopTimer"
onready var jump_buffer: Timer = $"%JumpBuffer"

onready var punch: Area2D = $"%Punch"

onready var weapon_slot = $"%WeaponSlot"

onready var rng = Globals.rng

var rigidbody_push = 300

export var enabled = true

var id: int setget set_id
var powerskulls = []
var chance_to_lose_skull = 0.5

var health: int = 3 setget set_health
var is_dead = false

var is_powered_up = false
var is_in_hit_stop = false
var is_stunned = false
var stun_triggered = false

func _ready():
	add_powerskull()
	state_manager.init()


func _process(delta):
	if powerskulls.size() >= 3:
		power_up()
	
	state_manager.process(delta)


func _physics_process(delta):
	state_manager.physics_process(delta)



func attacked(attack_direction: Vector2, attack_force: Vector2, health_lost: int = 0):
	if stun_triggered or is_stunned:
		return
	stun_triggered = true
	
	self.health -= health_lost
	
	var knockback_x_direction = sign(position.x - attack_direction.x)

	knockback_x_direction = knockback_x_direction if knockback_x_direction != 0 else [-1,1][rng.randi_range(0,1)]

	movement.velocity.x = attack_force.x * knockback_x_direction
	movement.velocity.y = attack_force.y
	
	
	
	if rng.randf_range(0.0, 1.0) >= chance_to_lose_skull:
		lose_powerskull()


func add_powerskull(powerskull_type: int = -1):
	if powerskull_type == -1:
		powerskull_type = rng.randi_range(0, Globals.powerskull_types.size() - 1)
	
	if powerskulls.size() < 3:
		powerskulls.append(powerskull_type)
		Events.emit_signal("skull_count_updated", self, powerskulls)


func lose_powerskull(skull_as_ammo := false):
	if powerskulls.size() == 0:
		return
	
	var removed_skull
	
	if powerskulls.size() > 0 and not skull_as_ammo:
		var remove_from_front = true if rng.randi_range(0, 1) == 0 else false
		
		if remove_from_front:
			removed_skull = powerskulls.pop_front()
		else:
			removed_skull = powerskulls.pop_back()
		
		print("removed:" + str(removed_skull))
	elif skull_as_ammo:
		removed_skull = powerskulls.pop_back()
		
		if powerskulls.size() == 0:
			power_down()

	Events.emit_signal("skull_lost", self, removed_skull, skull_as_ammo)
	Events.emit_signal("skull_count_updated", self, powerskulls)

func set_health(value):
	if is_stunned:
		return
	
	print(str(is_stunned))
	health = clamp(value, 0, 3)
	Events.emit_signal("player_health_updated", self, health)
	
	if health == 0:
		is_dead = true


func set_id(value):
	id = value
	Events.emit_signal("player_id_assigned", self)


func power_up():
	var weapon_scene = load(Globals.get_weapon())
	visuals.powerup_visuals.enabled = true
	weapon_slot.add_weapon(weapon_scene.instance())
	is_powered_up = true
	Events.emit_signal("player_powered_up", self)


func power_down():
	var weapon_scene = null
	visuals.powerup_visuals.enabled = false
	
	weapon_slot.remove_weapon()
	
	is_powered_up = false
	Events.emit_signal("player_powered_down", self)


func hit_stop(length := .1):
	set_process(false)
	set_physics_process(false)
	is_in_hit_stop = true
	
	visuals.sprite.material.set_shader_param("hit_stop", true)
	
	hit_stop_timer.wait_time = length
	hit_stop_timer.start()
	
	Globals.camera.shake(length)
	
	yield(hit_stop_timer,"timeout")
	
	visuals.sprite.material.set_shader_param("hit_stop", false)
	set_process(true)
	set_physics_process(true)
	is_in_hit_stop = false
	


