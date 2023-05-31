extends VoxelGeneratorScript

const Map_JSON = preload("res://assets/json/maps.json")
const _CHANNEL = VoxelBuffer.CHANNEL_TYPE
const _BLOCK_SIZE = 16
const CORNER = 0
const SIDE = 1
const MIDDLE = 2
const IMAGE_DIR = "res://assets/maps/"
const Y_COORD = 0

var map
var offset = Vector3i()
var _mutex = Mutex.new()
var _pois_rotations = {
	Vector3i(0, Y_COORD, 0): [0],
	Vector3i(48, Y_COORD, 0): [1],
	Vector3i(0, Y_COORD, 48): [3],
	Vector3i(48, Y_COORD, 48): [2],
}
var _palette = {}
var _pois
var spawn_points = []


func _init():
	if !G.post_ready.is_connected(post_ready):
		G.post_ready.connect(post_ready)
	var maps = Map_JSON.get_data()
	map = maps.get(G.vars.map)
	var imgs = map.variants.duplicate()
	_pois = {}
	for x in range(0, 100, 16):
		for z in range(0, 100, 16):
			_pois[Vector3i(x, Y_COORD, z)] = []
	for i in _pois_rotations.keys():
		var image_path = G.rng.pick_and_pop(imgs)
		for _story in range(5):
			var image = load(str(IMAGE_DIR, image_path, " (", _story+1, ").png")).get_image()
			var rotation = G.rng.pick(_pois_rotations[i])
			if rotation == 1:
				image.rotate_90(CLOCKWISE)
			elif rotation == 2:
				image.rotate_180()
			elif rotation == 3:
				image.rotate_90(COUNTERCLOCKWISE)
			_pois[i + Vector3i(0, 0, 0)].append(_crop(image, 0, 0))
			_pois[i + Vector3i(16, 0, 0)].append(_crop(image, 1, 0))
			_pois[i + Vector3i(32, 0, 0)].append(_crop(image, 2, 0))
			_pois[i + Vector3i(0, 0, 16)].append(_crop(image, 0, 1))
			_pois[i + Vector3i(0, 0, 32)].append(_crop(image, 0, 2))
			_pois[i + Vector3i(16, 0, 16)].append(_crop(image, 1, 1))
			_pois[i + Vector3i(32, 0, 16)].append(_crop(image, 2, 1))
			_pois[i + Vector3i(16, 0, 32)].append(_crop(image, 1, 2))
			_pois[i + Vector3i(32, 0, 32)].append(_crop(image, 2, 2))


func post_ready():
	_palette = G.blocks.to_dict()
	for i in map.palette.keys():
		var v = map.palette[i]
		_palette[i] = G.blocks.get_block_by_name(v)


func _generate_block(buffer: VoxelBuffer, origin: Vector3i, _lod: int):
	if origin.y == Y_COORD:
		buffer.fill_area(_palette["soil"].id,
			Vector3.ZERO, Vector3(16, 6, 16), _CHANNEL)
		if !_pois.is_empty():
			var poi = _pois.get(origin - offset)
			if poi != null:
				_load_image(buffer, origin, poi)
	else:
		buffer.fill(0, _CHANNEL)
	buffer.compress_uniform_channels()


func _crop(image, x, y):
	var r = Image.create(16, 16, true, image.get_format())
	r.blit_rect(image, Rect2i(x*16, y*16, 16, 16), Vector2i())
	return r


func _load_image(buffer: VoxelBuffer, origin: Vector3i, images):
	var lists = []
	for x in range(_BLOCK_SIZE):
		for z in range(_BLOCK_SIZE):
			var ceiling_pixel = images[0].get_pixel(x, z)
			lists.append(_load_floor(buffer, origin, ceiling_pixel, x, 15, z))
			lists.append(_load_wall(buffer, origin, images[1], x, 10, z))
			var floor_pixel = images[2].get_pixel(x, z)
			lists.append(_load_floor(buffer, origin, floor_pixel, x, 10, z))
			lists.append(_load_wall(buffer, origin, images[3], x, 5, z))
			var underground_floor_pixel = images[4].get_pixel(x, z)
			lists.append(_load_floor(buffer, origin, underground_floor_pixel, x, 5, z))
	var _cll = []
	var _cpll = []
	for i in lists:
		_cll += i[0]
		_cpll += i[1]
	_mutex.lock()
	G.late_loader.load_blocks[origin] = _cll
	G.late_loader.load_props[origin] = _cpll
	_mutex.unlock()


func _load_wall(buffer: VoxelBuffer, origin: Vector3, wall_image, x, y, z):
	var _chunk_late_loads = []
	var _chunk_prop_late_loads = []
	var wall_pixel = wall_image.get_pixel(x, z)
	if wall_pixel.a == 1.0:
		var r := roundi(wall_pixel.r * 4)
		var g := roundi(wall_pixel.g * 4)
		var b := roundi(wall_pixel.b * 4)
		var ox = x + origin.x
		var oy = y + origin.y
		var oz = z + origin.z
		var key = [r, g, b]
		match (key):
			[4,4,4]:
				buffer.set_voxel(2, x, y+1, z, _CHANNEL)
				buffer.set_voxel(2, x, y+2, z, _CHANNEL)
				buffer.set_voxel(2, x, y+3, z, _CHANNEL)
			[0,0,0]:
				buffer.fill_area(_palette["wall"].voxels[0],
					Vector3(x, y, z), Vector3(x + 1, y+5, z + 1), _CHANNEL)
			[1,1,1]:
				buffer.fill_area(_palette["wall2"].voxels[0],
					Vector3(x, y, z), Vector3(x + 1, y+5, z + 1), _CHANNEL)
			[2,2,2]:
				buffer.fill_area(_palette["wall"].voxels[0],
					Vector3(x, y, z), Vector3(x + 1, y+3, z + 1), _CHANNEL)
			[3,3,3]:
				buffer.fill_area(_palette["wall"].voxels[0],
					Vector3(x, y, z), Vector3(x + 1, y+2, z + 1), _CHANNEL)
			[2,1,0]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"table")
			[2,1,1]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"chair")
				_add_to_arr(_chunk_late_loads,ox,oy+3,oz,"spawner")
				buffer.set_voxel(2, x, y+2, z, _CHANNEL)
			[2,0,1]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"crate")
			[2,0,2]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"barrel")
			[0,1,4]:
				buffer.fill_area(_palette["wall"].voxels[0],
					Vector3(x, y, z), Vector3(x + 1, y+5, z + 1), _CHANNEL)
				buffer.set_voxel(_palette["glass"].voxels[0], x, y+2, z, _CHANNEL)
			[0,4,4]:
				buffer.fill_area(_palette["wall"].voxels[0],
					Vector3(x, y, z), Vector3(x + 1, y+5, z + 1), _CHANNEL)
				buffer.set_voxel(_palette["mirror"].voxels[0], x, y+2, z, _CHANNEL)
			[1,0,1]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"bookcase")
				_add_to_arr(_chunk_late_loads,ox,oy+2,oz,"bookcase")
			[1,0,2]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"cabinet")
				_add_to_arr(_chunk_late_loads,ox,oy+2,oz,"cabinet")
			[1,0,3]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"shelf")
				_add_to_arr(_chunk_late_loads,ox,oy+2,oz,"shelf")
			[1,0,4]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"trashcan")
			[1,1,0]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"solar panel")
			[2,0,0]:
				buffer.set_voxel(_palette["wall"].voxels[0], x, y+3, z, _CHANNEL)
				buffer.set_voxel(_palette["wall"].voxels[0], x, y+4, z, _CHANNEL)
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"shutter")
			[3,1,0]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"sofa")
			[3,0,0]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"campfire")
			[4,0,0]:
				buffer.set_voxel(_palette["wall"].voxels[0], x, y+3, z, _CHANNEL)
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"door")
				_add_to_arr(_chunk_late_loads,ox,oy+4,oz,"vent")
			[4,0,1]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"oven")
			[4,0,2]:
				_chunk_prop_late_loads.append([Vector3(ox, oy+1, oz), "vender"])
			[4,0,3]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"fridge")
				_add_to_arr(_chunk_late_loads,ox,oy+2,oz,"fridge")
			[4,0,4]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"table")
				_chunk_prop_late_loads.append([Vector3(ox, oy+2, oz), "console"])
			[4,2,0]:
				_add_to_arr(_chunk_late_loads,ox,oy+1,oz,"counter")
			[4,3,2]:
				buffer.set_voxel(2, x, y+1, z, _CHANNEL)
				_add_to_arr(_chunk_late_loads,ox,oy+2,oz,"divider")
			[3,2,0]:
				_chunk_prop_late_loads.append([Vector3(ox, oy+1, oz), "bed"])
			[4,3,0]:
				_chunk_prop_late_loads.append([Vector3(ox, oy+1, oz), "toilet"])
				spawn_points.append(Vector3(ox, oy+4, oz))
			[0,4,1]:
				_chunk_prop_late_loads.append([Vector3(ox, oy+1, oz), "pot"])
			[4,4,1]:
				_chunk_prop_late_loads.append([Vector3(ox, oy+3, oz), "torch"])
			[4,4,2]:
				_add_to_arr(_chunk_late_loads,ox,oy+4,oz,"strong light")
			_:
				var override = map.override.get(str(r,g,b))
				if override != null:
					_chunk_prop_late_loads.append([Vector3(ox, oy+1, oz), override])
	return [_chunk_late_loads, _chunk_prop_late_loads]


func _load_floor(buffer: VoxelBuffer, _origin: Vector3, ceiling_pixel: Color, x, y, z):
	var _chunk_late_loads = []
	var _chunk_prop_late_loads = []
	if ceiling_pixel.a == 1.0:
		var r := roundi(ceiling_pixel.r * 4)
		var g := roundi(ceiling_pixel.g * 4)
		var b := roundi(ceiling_pixel.b * 4)
		var key = [r, g, b]
		match (key):
			[1,1,1]:
				buffer.set_voxel(_palette["alley"].voxels[0], x, y, z, _CHANNEL)
			[2,2,2]:
				buffer.fill_area(_palette["wall"].voxels[0],
					Vector3(x, y-4, z), Vector3(x + 1, y-1, z + 1), _CHANNEL)
			[3,3,3]:
				buffer.fill_area(_palette["wall"].voxels[0],
					Vector3(x, y-4, z), Vector3(x + 1, y, z + 1), _CHANNEL)
			[3,4,0]:
				buffer.set_voxel(_palette["road"].voxels[0], x, y, z, _CHANNEL)
			[3,0,4]:
				buffer.set_voxel(_palette["special"].voxels[0], x, y, z, _CHANNEL)
			[2,1,0]:
				buffer.set_voxel(_palette["carpet"].voxels[0], x, y, z, _CHANNEL)
			[0,1,4]:
				buffer.set_voxel(_palette["glass"].voxels[0], x, y, z, _CHANNEL)
			[4,2,0]:
				buffer.set_voxel(_palette["tiles"].voxels[0], x, y, z, _CHANNEL)
			[4,4,4]:
				buffer.set_voxel(_palette["wall"].voxels[0], x, y, z, _CHANNEL)
	return [_chunk_late_loads, _chunk_prop_late_loads]


func _add_to_arr(arr, x,y,z, blockname):
	arr.append([Vector3(x,y,z), _palette[blockname].id])

