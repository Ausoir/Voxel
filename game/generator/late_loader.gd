extends Node


var load_blocks = {}
var load_props = {}
var _frame = 0
var _bounds
var _spawns


func _ready():
	stop()


func stop():
	set_process(false)


func _on_timeout():
	_bounds = G.terrain.generator.get_bounds()
	_spawns = G.mapdata.spawns.duplicate()
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
	G.you.global_position = spawn_point + G.V2_HALF
	G.ui.fadein()
	for pos in G.terrain.generator.item_points:
		var itemname = G.stock.make_group(G.mapdata.item)
		if itemname != null:
			var item = G.stock.make_item(itemname)
			item.drop_at(pos)
	set_process(true)


func _process(delta):
	_frame += delta
	if _frame > .2:
		_frame -= .2
		var current_spawning = _spawns.pop_front()
		if current_spawning == null:
			set_process(false)
		else:
			var search_voxels = []
			for block in current_spawning[0]:
				var voxel = G.blocks.get_block_by_name(block).voxels[0]
				search_voxels.append(voxel)
			for _i in range(current_spawning[1]):
				var interest_point = _get_interest_point(search_voxels)
				if interest_point != null:
					G.stock.make_any(interest_point + G.V_HALF, current_spawning[2])


func _get_interest_point(voxels):
	for _i in range(200):
		var x = G.rng.rir(_bounds[0], _bounds[2])
		var y = G.rng.rir(0, 32)
		var z = G.rng.rir(_bounds[1], _bounds[3])
		var pos = Vector3(x, y, z)
		var voxel = G.tool.get_voxel(pos)
		if voxel in voxels:
			var above = Vector3(x, y+1, z)
			if G.tool.get_voxel(above) < 5:
				return above
