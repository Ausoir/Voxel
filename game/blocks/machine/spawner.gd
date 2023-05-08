extends "../block.gd"


func on_tick(_pos: Vector3):
#	if randf() < .5:
#		G.stock.make_unit(_pos + Vector3(0, 2, 0), "janitor")
	G.tool.remove_block(_pos)
	return false
