extends Node


var load_blocks = {}
var load_props = {}
var _frame = 0
var _bounds
var _interests
var _times = 0


func _ready():
	set_process(false)


func _get_interest_point():
	for _i in range(400):
		var x = G.rng.rir(_bounds[0], _bounds[2])
		var y = G.rng.rir(0, 32)
		var z = G.rng.rir(_bounds[1], _bounds[3])
		var pos = Vector3(x, y, z)
		if G.tool.get_voxel(pos) in _interests:
			var above = Vector3(x, y+1, z)
			if G.tool.get_voxel(above) == 0:
				return above


func _process(delta):
	_frame += delta
	if _frame > .2:
		_frame -= .2
		_times -= 1
		if _times <= 0:
			set_process(false)
		else:
			for _i in range(4):
				var interest_point = _get_interest_point()
				if interest_point != null:
					spawn(interest_point)


func _on_timeout():
	_bounds = G.terrain.generator.bounds
	_interests = []
	for i in G.mapdata.spawnables:
		var voxel = G.blocks.get_block_by_name(i).voxels[0]
		_interests.append(voxel)
	for key in load_blocks.keys():
		var chunk = load_blocks[key]
		for next in chunk:
			var pos = next[0]
			var block_id = next[1]
			G.tool.set_block(pos, block_id, null)
	for key in load_props.keys():
		var chunk = load_props[key]
		for next in chunk:
			var pos = next[0]
			var objectname = next[1]
			G.stock.make_object(pos, objectname)
	load_blocks.clear()
	load_props.clear()
	var spawn_point = G.rng.pick(G.terrain.generator.spawn_points)
	if spawn_point == null:
		spawn_point = G.rng.pick_and_pop(_get_interest_point())
	G.you.global_position = spawn_point + G.V2_HALF
	G.ui.fadein()
	for i in G.mapdata.special:
		var interest_point = _get_interest_point()
		if interest_point != null:
			if G.tool.get_tool().get_voxel(interest_point) == 0:
				G.stock.make_object(interest_point, i)
	for pos in G.terrain.generator.item_points:
		var itemname = G.stock.make_group(G.mapdata.item, G.rng.rf())
		if itemname != null:
			var item = G.stock.make_item(itemname)
			item.drop_at(pos)
	_times = 60
	set_process(true)


func spawn(_pos):
	if G.tool.get_tool().get_voxel(_pos) == 0:
		var biome = G.get_biome(_pos)
		var unit = G.stock.make_group(G.mapdata.spawn, biome)
		if unit != null:
			G.stock.make_any(G.stock, _pos + G.V_HALF, unit)
