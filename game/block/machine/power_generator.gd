extends "../block.gd"


func on_hover(_pos: Vector3):
	G.ui.set_label(str("Current Power: ", G.faction.energy))
	return true


func on_tick(_pos: Vector3):
	if G.tool.raycast(_pos, Vector3.UP, 64) == null:
		G.faction.energy += data.get("power", 0)
	return true
