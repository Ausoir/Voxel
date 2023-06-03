extends Node


var load_blocks = {}
var load_props = {}


func _on_timeout():
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
		spawn_point = G.rng.pick_and_pop(G.terrain.generator.interest_points)
	G.you.global_position = spawn_point + G.V2_HALF
	G.ui.fadein()
	for i in G.mapdata.special:
		var interest_point = G.rng.pick_and_pop(G.terrain.generator.interest_points)
		if interest_point != null:
			if G.tool.get_tool().get_voxel(interest_point) == 0:
				G.stock.make_object(interest_point, i)
	for _i in range(240):
		var interest_point = G.rng.pick_and_pop(G.terrain.generator.interest_points)
		if interest_point != null:
			spawn(interest_point)
		else:
			break
	for pos in G.terrain.generator.item_points:
		var itemname = G.stock.make_group(G.mapdata.item, G.rng.rf())
		if itemname != null:
			var item = G.stock.make_item(itemname)
			item.drop_at(pos)


func spawn(_pos):
	if G.tool.get_tool().get_voxel(_pos) == 0:
		var biome = G.get_biome(_pos)
		var units = G.stock.make_group(G.mapdata.spawn, biome)
		if units != null:
			var unit = G.stock.make_group(units, G.rng.rf())
			if unit != null:
				G.stock.make_any(G.stock, _pos + G.V_HALF, unit)
