extends VoxelGeneratorScript

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE
const _BLOCK_SIZE = 16
const CORNER = 0
const SIDE = 1
const MIDDLE = 2
const IMAGE_DIR = "res://assets/maps/"
const Y_COORD = 0

var _late_loads = {}
var _door
var _light
var _table
var _chair
var _locker
var _counter
var _spawner
var _img_corners = ["cafe_"]
var pois = {
	Vector3i(0, Y_COORD, 0): [_img_corners, [0]],
	Vector3i(48, Y_COORD, 0): [_img_corners, [1]],
	Vector3i(0, Y_COORD, 48): [_img_corners, [3]],
	Vector3i(48, Y_COORD, 48): [_img_corners, [2]],
}


func _init():
	var new = {}
	for x in range(0, 100, 16):
		for z in range(0, 100, 16):
			new[Vector3i(x, Y_COORD, z)] = []
	for i in pois.keys():
		var image_path = G.rng.pick(pois[i][0])
		for _story in range(5):
			var image = load(str(IMAGE_DIR, image_path, _story, ".png")).get_image()
			var rotation = G.rng.pick(pois[i][1])
			if rotation == 1:
				image.rotate_90(CLOCKWISE)
			elif rotation == 2:
				image.rotate_180()
			elif rotation == 3:
				image.rotate_90(COUNTERCLOCKWISE)
			new[i + Vector3i(0, 0, 0)].append(_crop(image, 0, 0))
			new[i + Vector3i(16, 0, 0)].append(_crop(image, 1, 0))
			new[i + Vector3i(32, 0, 0)].append(_crop(image, 2, 0))
			new[i + Vector3i(0, 0, 16)].append(_crop(image, 0, 1))
			new[i + Vector3i(0, 0, 32)].append(_crop(image, 0, 2))
			new[i + Vector3i(16, 0, 16)].append(_crop(image, 1, 1))
			new[i + Vector3i(32, 0, 16)].append(_crop(image, 2, 1))
			new[i + Vector3i(16, 0, 32)].append(_crop(image, 1, 2))
			new[i + Vector3i(32, 0, 32)].append(_crop(image, 2, 2))
	pois = new
	G.connect("post_ready", Callable(self, "post_ready"))


func post_ready():
	_door = G.blocks.get_block_by_name("door").id
	_light = G.blocks.get_block_by_name("square light").id
	_table = G.blocks.get_block_by_name("table").id
	_chair = G.blocks.get_block_by_name("chair").id
	_locker = G.blocks.get_block_by_name("locker").id
	_counter = G.blocks.get_block_by_name("counter").id
	_spawner = G.blocks.get_block_by_name("spawner").id


func _generate_block(buffer: VoxelBuffer, origin: Vector3i, _lod: int):
	buffer.fill(0, _CHANNEL)
	if origin.y == Y_COORD and !pois.is_empty():
		var poi = pois.get(origin)
		if poi != null:
			_load_image(buffer, origin, poi)
	buffer.compress_uniform_channels()


func _crop(image, x, y):
	var r = Image.create(16, 16, true, image.get_format())
	r.blit_rect(image, Rect2i(x*16, y*16, 16, 16), Vector2i())
	return r


func _load_image(buffer: VoxelBuffer, origin: Vector3i, images):
	var _chunk_late_loads = []
	for x in range(_BLOCK_SIZE):
		for z in range(_BLOCK_SIZE):
			var ceiling_pixel = images[0].get_pixel(x, z)
			_chunk_late_loads += _load_floor(buffer, origin, ceiling_pixel, x, 15, z)
			_chunk_late_loads += _load_wall(buffer, origin, images[1], x, 10, z)
			var floor_pixel = images[2].get_pixel(x, z)
			_chunk_late_loads += _load_floor(buffer, origin, floor_pixel, x, 10, z)
			_chunk_late_loads += _load_wall(buffer, origin, images[3], x, 5, z)
			var underground_floor_pixel = images[4].get_pixel(x, z)
			_chunk_late_loads += _load_floor(buffer, origin, underground_floor_pixel, x, 5, z)
	_late_loads[origin] = _chunk_late_loads
	G.late_loader.load_blocks = _late_loads


func _load_wall(buffer: VoxelBuffer, origin: Vector3, wall_image, x, y, z):
	var _chunk_late_loads = []
	var wall_pixel = wall_image.get_pixel(x, z)
	if wall_pixel.a == 1.0:
		var r = int(wall_pixel.r * 3)
		var g = int(wall_pixel.g * 3)
		var b = int(wall_pixel.b * 3)
		var ox = x + origin.x
		var oy = y + origin.y
		var oz = z + origin.z
		match ([r, g, b]):
			[3,3,3]:
				buffer.set_voxel(2, x, y+1, z, _CHANNEL)
			[0,0,0]:
				buffer.fill_area(G.blocks.METAL,
					Vector3(x, y, z), Vector3(x + 1, y+5, z + 1), _CHANNEL)
			[1,1,1]:
				buffer.set_voxel(G.blocks.TILES, x, y+2, z, _CHANNEL)
			[2,2,2]:
				buffer.set_voxel(G.blocks.TILES, x, y+1, z, _CHANNEL)
			[1,0,0]:
				_chunk_late_loads.append([Vector3(ox, oy+1, oz), _table, null])
			[2,3,0]:
				_chunk_late_loads.append([Vector3(ox, oy+1, oz), _chair, null])
				_chunk_late_loads.append([Vector3(ox, oy+2, oz), _spawner, null])
			[0,3,0]:
				_chunk_late_loads.append([Vector3(ox, oy+1, oz), _locker, null])
			[0,0,3]:
				buffer.fill_area(G.blocks.METAL,
					Vector3(x, y, z), Vector3(x + 1, y+5, z + 1), _CHANNEL)
				buffer.set_voxel(G.blocks.GLASS, x, y+2, z, _CHANNEL)
			[0,2,3]:
				_chunk_late_loads.append([Vector3(ox, oy+1, oz), _table, null])
			[0,3,3]:
				buffer.fill_area(G.blocks.METAL,
					Vector3(x, y, z), Vector3(x + 1, y+5, z + 1), _CHANNEL)
				buffer.set_voxel(G.blocks.MIRROR, x, y+2, z, _CHANNEL)
			[3,0,0]:
				buffer.set_voxel(G.blocks.METAL, x, y+3, z, _CHANNEL)
				_chunk_late_loads.append([Vector3(ox, oy+1, oz), _door, null])
			[3,1,0]:
				_chunk_late_loads.append([Vector3(ox, oy+1, oz), _counter, null])
			[3,2,0]:
				G.late_loader.load_props.append([Vector3(ox, oy+1, oz), "toilet"])
	return _chunk_late_loads


func _load_floor(buffer: VoxelBuffer, origin: Vector3, ceiling_pixel: Color, x, y, z):
	var _chunk_late_loads = []
	if ceiling_pixel.a == 1.0:
		var r = int(ceiling_pixel.r * 3)
		var g = int(ceiling_pixel.g * 3)
		var b = int(ceiling_pixel.b * 3)
		var ox = x + origin.x
		var oy = y + origin.y
		var oz = z + origin.z
		match ([r, g, b]):
			[1,1,1]:
				buffer.set_voxel(G.blocks.TILES, x, y-2, z, _CHANNEL)
			[2,2,2]:
				buffer.set_voxel(G.blocks.TILES, x, y-1, z, _CHANNEL)
			[2,3,2]:
				buffer.set_voxel(G.blocks.WALKWAY, x, y+3, z, _CHANNEL)
			[0,0,3]:
				buffer.set_voxel(G.blocks.GLASS, x, y, z, _CHANNEL)
			[3,2,0]:
				buffer.set_voxel(G.blocks.METAL, x, y, z, _CHANNEL)
				_chunk_late_loads.append([Vector3(ox, oy-1, oz), _light, null])
			[1,1,0]:
				buffer.set_voxel(G.blocks.METAL, x, y, z, _CHANNEL)
				var list_strong = G.blocks.get_block_by_name("strong light").id
				_chunk_late_loads.append([Vector3(ox, oy-1, oz), list_strong, null])
			[3,1,0]:
				buffer.set_voxel(G.blocks.TILES, x, y, z, _CHANNEL)
			_:
				buffer.set_voxel(G.blocks.METAL, x, y, z, _CHANNEL)
	return _chunk_late_loads

