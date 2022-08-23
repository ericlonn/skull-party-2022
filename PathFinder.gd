extends Node

onready var tilemap := get_parent()

onready var a_star = AStar2D.new()

func _ready():
	var neighbor_offsets = []
	var used_cells = tilemap.get_used_cells()
	
	neighbor_offsets.append(Vector2(0,-1))
	neighbor_offsets.append(Vector2(0,1))
	neighbor_offsets.append(Vector2(-1,0))
	neighbor_offsets.append(Vector2(1,0))
	
	neighbor_offsets.append(Vector2(-1,-1))
	neighbor_offsets.append(Vector2(1,1))
	neighbor_offsets.append(Vector2(-1,1))
	neighbor_offsets.append(Vector2(1,-1))
	
	for cell in used_cells:
		if tilemap.get_cellv(cell) == 2:
			a_star.add_point(id(cell), cell, 1)
	
	for cell in used_cells:
		if tilemap.get_cellv(cell) != 2:
			continue
		
		for neighbor_offset in neighbor_offsets:
			var neighbor = cell + neighbor_offset
			if used_cells.has(neighbor) and a_star.has_point(id(neighbor)):
				a_star.connect_points(id(cell), id(neighbor))


func get_path_positions(start: Vector2, finish: Vector2):
	var start_cell = get_closest_cell(start)
	var start_id = id(start_cell)
	
	var finish_cell = get_closest_cell(finish)
	var finish_id = id(finish_cell)
	
	var path = a_star.get_point_path(start_id, finish_id)
	
	for i in path.size():
		path[i] = tilemap.map_to_world(path[i])
		path[i] += tilemap.cell_size / 2
	
	return path

func get_closest_cell(pos: Vector2):
	var closest_cell: Vector2

	for cell in tilemap.get_used_cells():
		if tilemap.get_cellv(cell) != 2:
			continue
		
		if closest_cell == null:
			closest_cell = cell
			continue
		
		var cur_cell_dist = pos.distance_to(tilemap.map_to_world(cell))
		var closest_cell_dist = pos.distance_to(tilemap.map_to_world(closest_cell))
		
		if cur_cell_dist < closest_cell_dist:
			closest_cell = cell
		
	return closest_cell


func id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b
