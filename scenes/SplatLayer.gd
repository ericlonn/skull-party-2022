class_name SplatLayer extends Node2D

export(int) var padding = 32

onready var mask_tilemap: TileMap = $MaskTileMap

onready var _canvas: Sprite = $Canvas
onready var _bg_canvas: Sprite = $BGCanvas
onready var _mask = $Mask
onready var test_sprite: Sprite = $HeartFull

var _tile_map: TileMap

func _ready():
	_tile_map = get_parent()
	
	var used_cells = _tile_map.get_used_cells()
	for cell in used_cells:
		mask_tilemap.set_cell(cell.x, cell.y, 0)
		
	
	var tile_map_rect = mask_tilemap.get_used_rect()
	var tile_map_size = tile_map_rect.size * mask_tilemap.cell_size
	print(mask_tilemap.cell_size)
	
	
	var itex := ImageTexture.new()
	var c_img := _create_image(tile_map_size)
	itex.create_from_image(c_img)
	_canvas.texture = itex
	_canvas.position = tile_map_rect.position
	_bg_canvas.texture = itex
	_bg_canvas.position = tile_map_rect.position

	var img_tex = _copy_tile_map_to_texture(mask_tilemap)
	_mask.texture = img_tex
	_mask.position = _canvas.position + img_tex.get_size() / 2 


func _create_image(size: Vector2) -> Image:
	var img := Image.new()
	
	img.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	return img


func _copy_tile_map_to_texture(tile_map: TileMap) -> ImageTexture:
	
	var cell_size := tile_map.get_cell_size()
	var tile_set := tile_map.tile_set
	var used_rect := tile_map.get_used_rect()
	var pad = Vector2.ONE * padding
	var img := _create_image(used_rect.size * cell_size)
	
	for tile in tile_map.get_used_cells():
		var tile_id := tile_map.get_cellv(tile)
		var tile_tex := Image.new()
		tile_tex.load(tile_set.tile_get_texture(tile_id).resource_path)
		var dst = tile*cell_size - used_rect.position * cell_size
		img.blit_rect(tile_tex, Rect2(Vector2.ZERO, tile_tex.get_size()), dst)
	
	var itex := ImageTexture.new()
	itex.create_from_image(img)
	
	return itex


func draw_spot(spot: Texture, pos: Vector2) -> void:
	var targets = [_canvas.texture, _bg_canvas.texture]
	var size = spot.get_size()
	var dst = pos - size/2
	
	for target in targets:
		var target_img = target.get_data()
		target_img.blend_rect(spot.get_data(), Rect2(Vector2.ZERO, size), dst)
		VisualServer.texture_set_data(target.get_rid(), target_img)
#	VisualServer.texture_set_data_partial(
#		target.get_rid(), spot.get_data(), 
#		0, 0,
#		size.x, size.y, 
#		dst.x, dst.y,
#		0, 0)


func _input(event):
	if event is InputEventMouseButton:
		draw_spot(test_sprite.texture, get_global_mouse_position())
