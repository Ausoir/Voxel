extends "../block.gd"


func on_tick(_pos: Vector3):
	var biome = G.get_biome(_pos)
	var units = G.stock.make_group("#fortress", biome)
	if units != null:
		var unit = G.stock.make_group(units, G.rng.rf())
		if unit != null:
			G.stock.make_any(G.stock, _pos + G.V_HALF, unit)
	G.tool.remove_block(_pos)
	return false
