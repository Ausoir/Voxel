extends Node

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE
const _BLOCK_SIZE = 16
const CORNER = 0
const SIDE = 1
const MIDDLE = 2

var image1 = preload("res://assets/maps/c1.png")
var image2 = preload("res://assets/maps/s1.png")
var image3 = preload("res://assets/maps/m1.png")
var _door
var _light
var _chunk_queue = []
var _furniture_queue = []
var pois = {
	Vector3i(0, 16, 0): [image1, [0]],
	Vector3i(32, 16, 0): [image2, [0]],
	Vector3i(64, 16, 0): [image1, [1]],
	Vector3i(0, 16, 32): [image2, [3]],
	Vector3i(32, 16, 32): [image3, [0,1,2,3]],
	Vector3i(64, 16, 32): [image2, [1]],
	Vector3i(0, 16, 64): [image1, [3]],
	Vector3i(32, 16, 64): [image2, [2]],
	Vector3i(64, 16, 64): [image1, [2]],
}


func _ready():
	_door = G.blocks.get_block_by_name("door").id
	_light = G.blocks.get_block_by_name("square light").id
	for i in pois.keys():
		var image = pois[i][0].get_image()
		var rotation = G.rng.pick(pois[i][1])
		if rotation == 1:
			image.rotate_90(CLOCKWISE)
		elif rotation == 2:
			image.rotate_180()
		elif rotation == 3:
			image.rotate_90(COUNTERCLOCKWISE)
		pois[i] = _crop(image, 0, 0)
		pois[i + Vector3i(16, 0, 0)] = _crop(image, 1, 0)
		pois[i + Vector3i(0, 0, 16)] = _crop(image, 0, 1)
		pois[i + Vector3i(16, 0, 16)] = _crop(image, 1, 1)
	set_process(false)


func _crop(image, x, y):
	var r = Image.create(16, 16, true, image.get_format())
	r.blit_rect(image, Rect2i(x*16, y*16, 16, 16), Vector2i())
	return r


func add_chunk_queue(origin: Vector3i):
	_chunk_queue.append(origin)
	set_process(true)


func _process(_delta):
	var chunk = _chunk_queue.pop_front()
	if chunk != null:
		if !pois.is_empty():
			var poi = pois.get(chunk)
			if poi != null:
				load_image(chunk, poi)
	else:
		var furniture = _furniture_queue.pop_front()
		if furniture != null:
			load_furniture(furniture)
		else:
			set_process(false)


func load_image(origin: Vector3i, poi):
	var image = poi
	var y = origin.y
	for _x in range(_BLOCK_SIZE):
		for _z in range(_BLOCK_SIZE):
			var x = _x + origin.x
			var z = _z + origin.z
			var pixel = image.get_pixel(_x, _z)
			if pixel.a == 1.0:
				var r = int(pixel.r * 3)
				var g = int(pixel.g * 3)
				var b = int(pixel.b * 3)
				if r == 0 and g == 0 and b == 0:
					for i in range(5):
						G.tool.place_voxel(Vector3(x, y + i, z), G.blocks.METAL)
				else:
					var pos = Vector3(x, y, z)
					for i in range(3):
						G.tool.place_voxel(Vector3(x, y + i + 1, z), 0)
					G.tool.place_voxel(pos, G.blocks.TILES)
					G.tool.place_voxel(Vector3(x, y + 4, z), G.blocks.METAL)
					_furniture_queue.append([[r,g,b], pos])


func load_furniture(furniture):
	var pos = furniture[1]
	match (furniture[0]):
		[1,1,1]:
			G.tool.place_voxel(pos + Vector3(0,3,0), G.blocks.METAL)
			if G.tool.get_voxel(pos + Vector3(1,2,0)) != 0:
				G.tool.place_block(pos + Vector3.UP, _door, Vector3.BACK)
			elif G.tool.get_voxel(pos + Vector3(-1,2,0)) != 0:
				G.tool.place_block(pos + Vector3.UP, _door, Vector3.BACK)
			else:
				G.tool.place_block(pos + Vector3.UP, _door, Vector3.LEFT)
		[2,2,2]:
			G.tool.place_voxel(pos, G.blocks.WALKWAY)
		[3,2,0]:
			G.tool.place_block(pos + Vector3(0,3,0), _light, Vector3.UP)
		[0,0,3]:
			for i in range(1, 4):
				G.tool.place_voxel(pos + Vector3(0,i,0), G.blocks.METAL)
			G.tool.place_voxel(pos + Vector3(0,2,0), G.blocks.GLASS)

