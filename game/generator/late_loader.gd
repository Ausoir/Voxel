extends Node


var load_blocks = {}
var load_props = {}
var _bounds
var _spawns
var _timeout = 0
var _player_spawned = false


func _ready():
	stop()


func stop():
	set_process(false)


func _on_timeout():
	_player_spawned = false
	_timeout = 100
	_bounds = G.terrain.generator.get_bounds()
	_spawns = {}
	var _prop_spawns = {}
	for key in G.mapdata.spawns.keys():
		var block = G.blocks.get_block_by_name(key)
		if block != null:
			_spawns[block.voxels[0]] = G.mapdata.spawns[key]
		else:
			_prop_spawns[key] = G.mapdata.spawns[key]
			print("Block not found: ", key)
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
			G.stock.make_object(pos + G.V2_HALF, objectname)
			if objectname in _prop_spawns:
				var prop_spawn = _prop_spawns[objectname]
				make_placeable(pos, prop_spawn[1])
				if prop_spawn[0] > 1:
					prop_spawn[0] -= 1
				else:
					_prop_spawns.erase(objectname)
	load_blocks.clear()
	load_props.clear()
	G.ui.fadein()
	for pos in G.terrain.generator.item_points:
		var itemname = G.stock.make_group(G.mapdata.item)
		if itemname != null:
			var item = G.stock.make_item(itemname)
			item.drop_at(pos)
	set_process(true)


func _process(_delta):
	if _spawns.is_empty():
		set_process(false)
	else:
		for _i in range(40):
			var x = G.rng.rir(_bounds[0], _bounds[2])
			var y = G.rng.rir(4, 13)
			var z = G.rng.rir(_bounds[1], _bounds[3])
			var pos = Vector3(x, y, z)
			var voxel = G.tool.get_voxel(pos)
			if voxel in _spawns.keys():
				var above = Vector3(x, y+1, z)
				if G.tool.get_voxel(above) < 4:
					var spawn_data = _spawns[voxel]
					make_placeable(above, spawn_data[1])
					if spawn_data[0] > 1:
						spawn_data[0] -= 1
					else:
						_spawns.erase(voxel)
						return
		_timeout -= 1
		if _timeout <= 0:
			print("LATE LOADER TIMEOUT", _spawns)
			_spawns.clear()


func move_player(pos):
	if !_player_spawned:
		G.you.position = pos + G.V2_HALF
		var from = pos - Vector3(8, 4, 8)
		G.tool.block_spawn(from, from + Vector3(16, 8, 16))
		_player_spawned = true


func make_placeable(pos, itemname):
	if itemname == "@":
		move_player(pos)
	else:
		var center = pos + G.V2_HALF
		if G.stock.make_any(center, itemname) == null and itemname[0] != "#":
			var block = G.blocks.get_block_by_name(itemname)
			if block != null:
				G.tool.set_block(pos, block.id, null)
			else:
				G.stock.make_object(center, itemname)

