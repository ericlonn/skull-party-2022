extends Timer

var buffered_wall_slide_x_dir = 0

func _process(delta):
	if time_left <= 0 or get_parent().get_parent().is_on_floor():
		buffered_wall_slide_x_dir = 0
		
	
