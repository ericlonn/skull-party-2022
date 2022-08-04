extends Panel

var assigned_player: Player setget set_assigned_player

onready var heart_tex1 = $VBoxContainer/PlayerHealthUI/Heart1
onready var heart_tex2 = $VBoxContainer/PlayerHealthUI/Heart2
onready var heart_tex3 = $VBoxContainer/PlayerHealthUI/Heart3
onready var ui_hearts = [heart_tex1, heart_tex2, heart_tex3]

export(Texture) var heart_empty_texture
export(Texture) var heart_full_texture
onready var empt_heart_color = Color.darkgray - Color(0,0,0,.3)

onready var skull_tex1 = $VBoxContainer/PlayerSkullsUI/Skull1
onready var skull_tex2 = $VBoxContainer/PlayerSkullsUI/Skull2
onready var skull_tex3 = $VBoxContainer/PlayerSkullsUI/Skull3
onready var ui_skulls = [skull_tex1, skull_tex2, skull_tex3]

onready var empty_skull_color = Color.darkgray - Color(0,0,0,.3)
var collected_anim_scale = 1.5
var collected_anim_time = 0.5

onready var tween: Tween = $Tween

var dead_player_ui_color = Color(.5,.5,.5,.5)
var death_fade_time = .5

func _ready():
	visible = false
	
	for uiskull in ui_skulls:
		uiskull.modulate = empty_skull_color
	
	Events.connect("skull_count_updated", self, "_on_Player_skull_count_updated")
	Events.connect("player_health_updated", self, "_on_Player_health_updated")
	Events.connect("player_died", self, "on_Player_died")


func set_skull_count():
	pass


func _on_Player_skull_count_updated(player: Player, skulls):
	if player != assigned_player:
		return
	
	var previous_skull_count = 0
	for ui_skull in ui_skulls:
		if ui_skull.modulate != empty_skull_color:
			previous_skull_count += 1
	
	var i = 0
	for ui_skull in ui_skulls:
		if i < skulls.size():
			ui_skull.modulate = Globals.get_skull_color(skulls[i])
			
			if i + 1 > previous_skull_count:
				tween.interpolate_property(ui_skull, "rect_scale", ui_skull.rect_scale, \
				ui_skull.rect_scale * collected_anim_scale, collected_anim_time / 2, \
				Tween.TRANS_QUINT, Tween.EASE_OUT)
				tween.interpolate_property(ui_skull, "rect_scale", ui_skull.rect_scale * collected_anim_scale, \
				ui_skull.rect_scale, collected_anim_time / 2, \
				Tween.TRANS_QUINT, Tween.EASE_OUT, collected_anim_time / 2)
				tween.start()
		else:
			ui_skull.modulate = empty_skull_color
		i += 1


func _on_Player_health_updated(player, new_value):
	if player != assigned_player:
		return
	
	var previous_heart_count = 0
	for ui_heart in ui_hearts:
		if ui_heart.texture == heart_full_texture:
			previous_heart_count += 1
	
	for i in ui_hearts.size():
		if i < new_value:
			ui_hearts[i].texture = heart_full_texture
			ui_hearts[i].modulate = Color.white
		else:
			ui_hearts[i].texture = heart_empty_texture
			ui_hearts[i].modulate = empt_heart_color
		
		if i + 1 > previous_heart_count and ui_hearts[i].texture == heart_full_texture:
			tween.interpolate_property(ui_hearts[i], "rect_scale", ui_hearts[i].rect_scale, \
			ui_hearts[i].rect_scale * collected_anim_scale, collected_anim_time / 2, \
			Tween.TRANS_QUINT, Tween.EASE_OUT)
			tween.interpolate_property(ui_hearts[i], "rect_scale", ui_hearts[i].rect_scale * collected_anim_scale, \
			ui_hearts[i].rect_scale, collected_anim_time / 2, \
			Tween.TRANS_QUINT, Tween.EASE_OUT, collected_anim_time / 2)
			tween.start()


func set_assigned_player(value):
	assigned_player = value
	var player_color = Globals.get_player_color(assigned_player.id)
	get_stylebox("panel", "").border_color = player_color
	
	_on_Player_health_updated(assigned_player, assigned_player.health)
	_on_Player_skull_count_updated(assigned_player, assigned_player.powerskulls)
	
	visible = true


func on_Player_died(player, color, death_location):
	if player == assigned_player:
		tween.reset_all()
		tween.interpolate_property(self, "modulate", modulate, dead_player_ui_color, death_fade_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
