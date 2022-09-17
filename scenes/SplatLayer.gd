class_name SplatLayer extends Node2D

export(int) var padding = 32
export(Array, Texture) var splat_textures
export(PackedScene) var splat_scene

onready var mask_tilemap: TileMap = $MaskTileMap

onready var _bg_mask: Light2D = $BGMask
onready var _mask = $Mask


onready var rng := RandomNumberGenerator.new()

var _tile_map: TileMap


func _ready():
	rng.randomize()
	
	Events.connect("player_died", self, "on_Player_died")
	
	_tile_map = get_parent()
	
	var used_cells = _tile_map.get_used_cells()
	for cell in used_cells:
		mask_tilemap.set_cell(cell.x, cell.y, 0)
		
	
	var tile_map_rect = mask_tilemap.get_used_rect()
	var tile_map_size = tile_map_rect.size * mask_tilemap.cell_size
	
	
	var itex := ImageTexture.new()
	var c_img := _create_image(tile_map_size)
#	itex.create_from_image(c_img)
	_bg_mask.texture = itex
	_bg_mask.position = tile_map_rect.position + itex.get_size() / 2

	var img_tex = _copy_tile_map_to_texture(mask_tilemap)
	_mask.texture = img_tex
	_mask.position = mask_tilemap.position + img_tex.get_size() / 2 


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
		
		var tile_tex = Image.new()
		tile_tex.create(tile_map.cell_size.x, tile_map.cell_size.y, false, Image.FORMAT_RGBA8)
		tile_tex.fill(Color.white)
		
		var dst = tile*cell_size - used_rect.position * cell_size
		img.blit_rect(tile_tex, Rect2(Vector2.ZERO, tile_tex.get_size()), dst)
	
	var itex := ImageTexture.new()
	itex.create_from_image(img)
	
	return itex


func on_Player_died(player, color, death_location):
	var new_splat = splat_scene.instance()
	add_child(new_splat)
	
	new_splat.color = color
	new_splat.global_position = death_location
	
	
#	var splat_texture_index = RNGTools.randi_range(0, splat_textures.size() - 1)
#	var splat_texture: Texture = splat_textures[splat_texture_index]
#	temp_splat_sprite.texture = splat_textures[splat_texture_index]
#	viewport.size = splat_texture.get_size()
#
#	temp_splat_sprite.modulate = color
#	temp_splat_sprite.rotation_degrees = rng.randf_range(0, 360)
#
#	var splat_draw_image: Image = viewport.get_texture().get_data()
#	var splat_draw_texture: Texture = ImageTexture.new()
#	splat_draw_texture.create_from_image(splat_draw_image)
#
#	draw_spot(splat_draw_texture, death_location)
#	temp_splat_sprite.texture = null
#	var splat_image := Image.new()
#	splat_image.load(splat_textures[splat_texture_index].resource_path)
#
#	splat_image.fill(color)
#
#	var splat_tex := ImageTexture.new()
#	splat_tex.create_from_image(splat_image)
#
#	draw_spot(splat_tex, death_location)
	
