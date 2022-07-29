tool
extends Node2D
class_name SkullSpawnPoint

onready var sprite: Sprite = $Sprite
onready var label: Label = $Label

func _ready():
	if Engine.editor_hint:
		sprite.visible = true
		label.visible = true
	else:
		sprite.visible = false
		label.visible = false
