extends "../block.gd"

const Door = preload("./prop_divider.tscn")
var door


func on_remove(_pos: Vector3):
	G.stock.remove_child(door)
	if door != null:
		door.queue_free()
		door = null


func on_interact(_pos: Vector3, _user: Node3D):
	var voxel = G.tool.get_voxel(_pos)
	door = Door.instantiate()
	door.voxel_pos = _pos
	G.tool.set_voxel(_pos, 0)
	G.stock.add_child(door)
	door.voxel_id = voxel
	door.position = door.voxel_pos
	if voxel == voxels[1]:
		door.rotation.y = PI / -2.0
		door.position.x += 1
	door.get_node("Animator").play("open")

