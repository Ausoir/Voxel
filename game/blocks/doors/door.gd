extends "../block.gd"

const Door = preload("./prop_door.tscn")


func on_place(_pos: Vector3):
	var above = _pos + Vector3.UP
	var current_voxel = G.tool.get_voxel(_pos)
	var current_id = voxels.find(current_voxel)
	G.tool.set_voxel(above, voxels[current_id + 2])


func on_interact(_pos: Vector3, _user: Node3D):
	var door = Door.instantiate()
	var voxel = G.tool.get_voxel(_pos)
	door.voxel_pos = _pos
	door.voxel_id = voxel
	G.tool.remove_block(_pos)
	G.stock.add_child(door)
	door.position = _pos
	if voxel == voxels[0]:
		door.rotation.y = PI / -2.0
		door.position.x += 1
	door.get_node("Animator").play("open")

