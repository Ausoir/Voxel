extends Node


var load_blocks = {}
var load_props = {}
var _bounds
var _spawns
var _timeout = 0
var _player_spawned = false
var _spawn_units = []


func _ready():
	stop()


func stop():
	set_process(false)


func _on_timeout():
	_spawn_units = []
	_player_spawned = false
	_timeout = 200
	_bounds = G.terrain.generator.get_bounds()
	_spawns = {}
	var _prop_spawns = {}
	for key in G.mapdata.spawns.keys():
		var block = G.blocks.get_block_by_name(key.substr(1))
		if block != null:
			_spawns[str(key[0], block.voxels[0])] = G.mapdata.spawns[key].duplicate(true)
		else:
			_prop_spawns[key] = G.mapdata.spawns[key].duplicate(true)
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
			var spawn_key
			if pos.y >= 7:
				spawn_key = "^" + objectname
			else:
				spawn_key = "_" + objectname
			if spawn_key in _prop_spawns:
				var above = Vector3(pos.x, pos.y+1, pos.z)
				if G.tool.get_voxel(above) < 4:
					var prop_spawn_list = _prop_spawns[spawn_key]
					for i in range(prop_spawn_list.size()-1,-1,-1):
						var prop_spawn = prop_spawn_list[i]
						var spawn_params = prop_spawn[0]
						if spawn_params > 0:
							if spawn_params < 1:
								if G.rng.percent(spawn_params):
									make_placeable(above, prop_spawn[1])
									break
							else:
								make_placeable(above, prop_spawn[1])
								if spawn_params > 1:
									prop_spawn[0] -= 1
								else:
									prop_spawn_list.pop_at(i)
								break
					if prop_spawn_list.is_empty():
						_prop_spawns.erase(spawn_key)
					else:
						_prop_spawns[spawn_key] = prop_spawn_list
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
			var y = G.rng.rir(5, 12)
			var z = G.rng.rir(_bounds[1], _bounds[3])
			var pos = Vector3(x, y, z)
			var voxel = G.tool.get_voxel(pos)
			var spawn_key
			if y >= 10:
				spawn_key = str("^", voxel)
			else:
				spawn_key = str("_", voxel)
			if spawn_key in _spawns.keys():
				var above = Vector3(x, y+1, z)
				if G.tool.get_voxel(above) < 4:
					var spawn_data_list = _spawns[spawn_key]
					for i in range(spawn_data_list.size()-1,-1,-1):
						var spawn_data = spawn_data_list[i]
						if spawn_data[0] > 0:
							if spawn_data[0] < 1:
								if G.rng.percent(spawn_data[0]):
									make_placeable(above, spawn_data[1])
									break
							else:
								make_placeable(above, spawn_data[1])
								if spawn_data[0] > 1:
									_spawns[spawn_key][i][0] = spawn_data[0] - 1
								else:
									spawn_data_list.pop_at(i)
								break
					if spawn_data_list.is_empty():
						_spawns.erase(spawn_key)
					else:
						_spawns[spawn_key] = spawn_data_list
		_timeout -= 1
		if _timeout <= 0:
			print("LATE LOADER TIMEOUT", _spawns)
			_spawns.clear()


func move_player(pos):
	if !_player_spawned:
		var player_pos = pos + G.V2_HALF
		G.you.position = player_pos
		_player_spawned = true
		for i in range(_spawn_units.size()-1, -1, -1):
			var unit = _spawn_units[i]
			var dx = abs(unit.position.x - player_pos.x)
			var dy = abs(unit.position.y - player_pos.y)
			var dz = abs(unit.position.z - player_pos.z)
			if dx < 7 and dz < 7 and dy < 5:
				unit.remove()


func make_placeable(pos, itemname):
	if itemname == "@":
		move_player(pos)
	else:
		var center = pos + G.V2_HALF
		var real_itemname = G.stock.make_group(itemname)
		if real_itemname != null:
			var mob = G.stock.make_mob(center, real_itemname)
			if mob != null:
				_spawn_units += mob
				for i in mob:
					G.tool.set_voxel(i.position, 4)
			elif !_player_spawned or G.you.position.distance_squared_to(center) > 120:
				var unit = G.stock.make_unit(center, real_itemname)
				if unit != null:
					_spawn_units.append(unit)
					G.tool.set_voxel(center, 4)
				else:
					var block = G.blocks.get_block_by_name(real_itemname)
					if block != null:
						G.tool.set_block(pos, block.id, null)
					else:
						var item = G.stock.make_item(real_itemname)
						if item == null:
							G.stock.make_object(center, real_itemname)
						else:
							item.drop_at(center)

