extends "../block.gd"

const Door = preload("./prop_door.tscn")


func on_hover(_pos: Vector3):
	var text = str("Voxel ", " ", G.tool.get_voxel(_pos))
	G.ui.set_label(text)
	return true


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

