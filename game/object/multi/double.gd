extends "../block.gd"


func on_place(_pos: Vector3):
	var above = _pos + Vector3.UP
	G.tool.set_voxel(above, voxels[1])

