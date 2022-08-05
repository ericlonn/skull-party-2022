extends Node2D

func _ready():
	Fmod.set_software_format(0, Fmod.FMOD_SPEAKERMODE_STEREO, 0)
	Fmod.init(1024, Fmod.FMOD_STUDIO_INIT_LIVEUPDATE, Fmod.FMOD_INIT_NORMAL)
	
	Fmod.load_bank("res://audio/skull_party/Build/Desktop/Master.strings.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	Fmod.load_bank("res://audio/skull_party/Build/Desktop/Master.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	
	Events.connect("player_death_begun", self, "on_Player_death_begun")
	Events.connect("player_died", self, "on_Player_died")
	Events.connect("skull_collected", self, "on_Skull_collected")
	Events.connect("chest_shattered", self, "on_Chest_shattered")


func on_Player_death_begun(player):
	Fmod.play_one_shot("event:/Player/Death/DeathCharging", self)


func on_Player_died(player, color, death_location):
	Fmod.play_one_shot("event:/Player/Death/DeathPop", self)


func on_Skull_collected(skull):
	Fmod.play_one_shot("event:/Items/Powerskulls/Collected", self)


func on_Chest_shattered(chest):
	print("chest shattered")
	Fmod.play_one_shot("event:/Items/Chest/Break", self)
