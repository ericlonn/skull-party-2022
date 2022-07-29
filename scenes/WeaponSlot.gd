extends Node2D

onready var bullet_spawn_point: Node2D = $BulletSpawnPoint

var super_weapon: SuperWeapon = null
var parent_player: Player

func _ready():
	find_parent_player()
	print(parent_player.name)

func add_weapon(weapon: SuperWeapon):
	var has_superweapon = false
	
	for child in get_children():
		if child is SuperWeapon:
			has_superweapon = true
	
	if has_superweapon:
		return
		
	weapon.bullet_spawn_point = bullet_spawn_point
	add_child(weapon)
	weapon.parent_player = parent_player
	
	super_weapon = weapon

func remove_weapon():
	for child in get_children():
		if child is SuperWeapon:
			child.queue_free()
	
	super_weapon = null

func fire_weapon():
	if super_weapon != null:
		super_weapon.fire()


func find_parent_player():
	var max_attempts = 5
	
	var possible_parent = get_parent()
	if possible_parent is Player:
		parent_player = possible_parent
		return
	
	for i in max_attempts:
		possible_parent = possible_parent.get_parent()
		if possible_parent is Player:
			parent_player = possible_parent
			break
	
