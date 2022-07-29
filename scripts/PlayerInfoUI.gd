extends Panel

var assigned_player_id setget set_assigned_player_id

onready var skull_tex1 = $VBoxContainer/PlayerSkullsUI/Skull1
onready var skull_tex2 = $VBoxContainer/PlayerSkullsUI/Skull2
onready var skull_tex3 = $VBoxContainer/PlayerSkullsUI/Skull3

onready var ui_skulls = [skull_tex1, skull_tex2, skull_tex3]

onready var tween: Tween = $Tween

var empty_skull_color = Color.gray
var collected_skull_anim_scale = 1.5
var collected_skull_anim_time = 0.5


func _ready():
	visible = false
	
	for uiskull in ui_skulls:
		uiskull.modulate = empty_skull_color
	
	Events.connect("skull_count_updated", self, "_on_Player_skull_count_updated")


func set_skull_count():
	pass


func _on_Player_skull_count_updated(player: Player, skulls):
	if player.id != assigned_player_id:
		return
	
	var previous_skull_count = 0
	for ui_skull in ui_skulls:
		if ui_skull.modulate != empty_skull_color:
			previous_skull_count += 1
	
	var i = 0
	for ui_skull in ui_skulls:
		if i < skulls.size():
			ui_skull.modulate = Rules.get_skull_color(skulls[i])
			
			if i + 1 > previous_skull_count:
				tween.interpolate_property(ui_skull, "rect_scale", ui_skull.rect_scale, \
				ui_skull.rect_scale * collected_skull_anim_scale, collected_skull_anim_time / 2, \
				Tween.TRANS_QUINT, Tween.EASE_OUT)
				tween.interpolate_property(ui_skull, "rect_scale", ui_skull.rect_scale * collected_skull_anim_scale, \
				ui_skull.rect_scale, collected_skull_anim_time / 2, \
				Tween.TRANS_QUINT, Tween.EASE_OUT, collected_skull_anim_time / 2)
				tween.start()
		else:
			ui_skull.modulate = empty_skull_color
		i += 1


func set_assigned_player_id(value):
	assigned_player_id = value
	var player_color = Rules.get_player_color(assigned_player_id)
	get_stylebox("panel", "").border_color = player_color
	
	visible = true
