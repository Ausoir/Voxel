extends VoxelGeneratorScript

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE
const _BLOCK_SIZE = 16
const CORNER = 0
const SIDE = 1
const MIDDLE = 2
const IMAGE_DIR = "res://assets/maps/"

var _late_loads = {}
var _door
var _light
var _table
var _chair
var _locker
var _spawner
var _img_corners = ["c_offices_"]
var _img_sides = ["s_cafeteria_"]
var _img_middle = ["m_servers_"]
var pois = {
	Vector3i(0, 16, 0): [_img_corners, [0]],
	Vector3i(32, 16, 0): [_img_sides, [0]],
	Vector3i(64, 16, 0): [_img_corners, [1]],
	Vector3i(0, 16, 32): [_img_sides, [3]],
	Vector3i(32, 16, 32): [_img_middle, [0,1,2,3]],
	Vector3i(64, 16, 32): [_img_sides, [1]],
	Vector3i(0, 16, 64): [_img_corners, [3]],
	Vector3i(32, 16, 64): [_img_sides, [2]],
	Vector3i(64, 16, 64): [_img_corners, [2]],
}


func _init():
	var new = {}
	for x in range(0, 81, 16):
		for z in range(0, 81, 16):
			new[Vector3i(x, 16, z)] = []
	for i in pois.keys():
		var image_path = G.rng.pick(pois[i][0])
		for _story in range(2):
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
			new[i + Vector3i(0, 0, 16)].append(_crop(image, 0, 1))
			new[i + Vector3i(16, 0, 16)].append(_crop(image, 1, 1))
	pois = new
	G.connect("post_ready", Callable(self, "post_ready"))


func post_ready():
	_door = G.blocks.get_block_by_name("door").id
	_light = G.blocks.get_block_by_name("square light").id
	_table = G.blocks.get_block_by_name("table").id
	_chair = G.blocks.get_block_by_name("chair").id
	_locker = G.blocks.get_block_by_name("locker").id
	_spawner = G.blocks.get_block_by_name("spawner").id


func _generate_block(buffer: VoxelBuffer, origin: Vector3i, _lod: int):
	buffer.fill(0, _CHANNEL)
	if origin.y == 16 or origin.y == 32 and !pois.is_empty():
		var poi = pois.get(origin)
		if poi != null:
			_load_image(buffer, origin, poi)
	buffer.compress_uniform_channels()


static func _get_chunk_seed_2d(cpos: Vector3) -> int:
	return int(cpos.x) ^ (31 * int(cpos.z))


func _crop(image, x, y):
	var r = Image.create(16, 16, true, image.get_format())
	r.blit_rect(image, Rect2i(x*16, y*16, 16, 16), Vector2i())
	return r


func _is_passable(color: Color):
	return color.r + color.g + color.b > 2.0


func _load_image(buffer: VoxelBuffer, origin: Vector3i, images):
	var _chunk_late_loads = []
	for x in range(_BLOCK_SIZE):
		for z in range(_BLOCK_SIZE):
			var floor_blueprint = images[0]
			var pixel = floor_blueprint.get_pixel(x, z)
			var ox = x + origin.x
			var oy = origin.y
			var oz = z + origin.z
			if pixel.a == 1.0:
				var r = int(pixel.r * 3)
				var g = int(pixel.g * 3)
				var b = int(pixel.b * 3)
				if r == 0 and g == 0 and b == 0:
					buffer.fill_area(G.blocks.METAL,
						Vector3(x, 0, z), Vector3(x + 1, 6, z + 1), _CHANNEL)
				else:
					buffer.fill_area(0,
						Vector3(x, 0, z), Vector3(x + 1, 5, z + 1), _CHANNEL)
					buffer.set_voxel(G.blocks.METAL, x, 5, z, _CHANNEL)
					match ([r, g, b]):
						[1,1,1]:
							buffer.set_voxel(G.blocks.TILES, x, 1, z, _CHANNEL)
							buffer.set_voxel(G.blocks.METAL, x, 4, z, _CHANNEL)
							if x < _BLOCK_SIZE-1 and _is_passable(floor_blueprint.get_pixel(x+1, z)):
								_chunk_late_loads.append([Vector3(ox, oy+2, oz), _door, Vector3.BACK])
							elif x > 0 and _is_passable(floor_blueprint.get_pixel(x-1, z)):
								_chunk_late_loads.append([Vector3(ox, oy+2, oz), _door, Vector3.BACK])
							else:
								_chunk_late_loads.append([Vector3(ox, oy+2, oz), _door, Vector3.FORWARD])
						[2,2,2]:
							buffer.set_voxel(G.blocks.WALKWAY, x, 1, z, _CHANNEL)
							buffer.set_voxel(G.blocks.WALKWAY, x, 4, z, _CHANNEL)
						[1,0,0]:
							buffer.set_voxel(G.blocks.TILES, x, 1, z, _CHANNEL)
							_chunk_late_loads.append([Vector3(ox, oy+2, oz), _table, Vector3.BACK])
							_chunk_late_loads.append([Vector3(ox, oy+4, oz), _light, Vector3.BACK])
						[3,1,0]:
							buffer.set_voxel(G.blocks.TILES, x, 1, z, _CHANNEL)
							_chunk_late_loads.append([Vector3(ox, oy+2, oz), _chair, Vector3.BACK])
							_chunk_late_loads.append([Vector3(ox, oy+3, oz), _spawner, Vector3.BACK])
						[0,3,0]:
							buffer.set_voxel(G.blocks.TILES, x, 1, z, _CHANNEL)
							_chunk_late_loads.append([Vector3(ox, oy+2, oz), _locker, Vector3.BACK])
						[0,0,3]:
							buffer.fill_area(G.blocks.METAL,
								Vector3(x, 0, z), Vector3(x + 1, 5, z + 1), _CHANNEL)
							buffer.set_voxel(G.blocks.GLASS, x, 3, z, _CHANNEL)
						_:
							buffer.set_voxel(G.blocks.TILES, x, 1, z, _CHANNEL)
	_late_loads[origin] = _chunk_late_loads
	G.late_loader.load_props = _late_loads
