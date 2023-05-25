extends "../block.gd"


func on_tick(_pos: Vector3):
	if randf() < .1:
		G.stock.make_humanoid(G.stock, _pos + G.V_HALF, "security")
	G.tool.remove_block(_pos)
	return false
