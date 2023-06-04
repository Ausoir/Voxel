extends "./block.gd"


func on_hover(_pos):
	var meta = G.tool.get_tool().get_voxel_metadata(_pos)
	if meta != null:
		G.ui.set_label(str(meta))
		return true
