extends "../block.gd"


func on_tick(_pos: Vector3):
	var unit = G.stock.make_group(data.get("spawns", []))
	if unit != null:
		G.stock.make_any_unit(G.stock, _pos + G.V_HALF, unit)
	G.tool.remove_block(_pos)
	return false
