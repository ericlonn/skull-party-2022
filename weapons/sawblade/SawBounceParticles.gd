extends Particles2D

onready var timeout := Timer.new()

func _ready():
	emitting = true


func _on_Timer_timeout():
	queue_free()
