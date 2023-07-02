extends Node

const IMAGE_DIR = "res://assets/maps/"
const BLANK = preload("res://assets/maps/blank.png")
var _palette
var _pois
var loads = []
var _pois_rotations = {
	Vector3i(0, 0, 0): [0],
	Vector3i(48, 0, 0): [1],
	Vector3i(0, 0, 48): [3],
	Vector3i(48, 0, 48): [2],
}


func _ready():
	_palette = G.blocks.to_dict().duplicate()
	for i in G.mapdata.palette.keys():
		var palette = G.mapdata.palette[i]
		var arr = []
		for v in palette:
			if v != null:
				var block = G.blocks.get_block_by_name(v)
				if block != null:
					arr.append(block.id)
				else:
					arr.append(v)
			else:
				arr.append(null)
		_palette[i] = arr

	G.rng.set_seed(G.vars.seed - 234568)

	var imgs = G.mapdata.variants.duplicate()
	_pois = {}
	for x in range(0, 100, 16):
		for z in range(0, 100, 16):
			_pois[Vector3i(x, 0, z)] = []
	for i in _pois_rotations.keys():
		var image_path = G.rng.pick_and_pop(imgs)
		var path = str(IMAGE_DIR, image_path, ".png")
		var image
		if ResourceLoader.exists(path):
			image = load(path).get_image()
		else:
			image = BLANK.get_image()
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
	set_process(true)


func _crop(image, x, y):
	var r = Image.create(16, 16, true, image.get_format())
	r.blit_rect(image, Rect2i(x*16, y*16, 16, 16), Vector2i())
	return r


func _process(_delta):
	var next_load = loads.pop_front()
	if next_load != null:
		if !_pois.is_empty():
			var poi = _pois.get(next_load)
			if poi != null and !poi.is_empty():
				load_chunk(next_load, poi)
				_pois.erase(poi)
	else:
		set_process(false)
		G.ui.fadein()


func load_chunk(origin: Vector3, images):
	for x in range(16):
		for z in range(16):
			var ceiling_pixel = images[0].get_pixel(x, z)
			var ox = origin.x + x
			var oz = origin.z + z
			_load_pixel(ceiling_pixel, ox, 5, oz)


func _load_pixel(pixel, x, y, z):
	if pixel.a == 1.0:
		var r := roundi(pixel.r * 4)
		var g := roundi(pixel.g * 4)
		var b := roundi(pixel.b * 4)
		var key = str(r,g,b)
		var v = _palette.get(key)
		if v != null:
			for i in range(v.size()):
				_place(Vector3(x, y+i, z), v[i])


func _place(pos, item):
	if item != null:
		if item is String:
			var split = item.split("|")
			var ssize = split.size()
			if ssize == 1:
				G.stock.make_object(pos + G.V2_HALF, item)
			else:
				for i in range(ssize):
					if G.rng.rb():
						var itemname = split[i]
						if !itemname.is_empty():
							var block = G.blocks.get_block_by_name(itemname)
							if block != null:
								G.tool.set_block(pos, block.id, null)
							elif itemname == "@":
								G.you.global_position = pos + G.V2_HALF
							else:
								G.stock.make_object(pos + G.V2_HALF, itemname)
						break
		else:
			G.tool.set_block(pos, item, null)

