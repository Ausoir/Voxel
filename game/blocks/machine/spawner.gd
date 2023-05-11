extends "../block.gd"


func on_tick(_pos: Vector3):
	if randf() < .4:
		G.stock.make_humanoid(G.stock, _pos + Vector3(.5, .5, .5), "security")
	G.tool.remove_block(_pos)
	return false
