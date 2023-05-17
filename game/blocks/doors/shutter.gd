extends "../block.gd"

const Door = preload("./prop_shutter.tscn")
var door


func on_place(_pos: Vector3):
	var above = _pos + Vector3.UP
	var current_voxel = G.tool.get_voxel(_pos)
	G.tool.set_voxel(above, current_voxel)


func on_remove(_pos: Vector3):
	G.stock.remove_child(door)
	if door != null:
		door.queue_free()
		door = null


func on_interact(_pos: Vector3, _user: Node3D):
	var voxel = G.tool.get_voxel(_pos)
	var above = G.tool.get_voxel(_pos + Vector3.UP)
	if above == voxel:
		door = Door.instantiate()
		door.voxel_pos = _pos
		G.tool.set_voxel(_pos + Vector3.UP, 0)
	elif G.tool.get_voxel(_pos + Vector3.DOWN) == voxel:
		door = Door.instantiate()
		door.voxel_pos = _pos + Vector3.DOWN
		G.tool.set_voxel(_pos + Vector3.DOWN, 0)
	else:
		return
	G.tool.set_voxel(_pos, 0)
	G.stock.add_child(door)
	door.voxel_id = voxel
	door.position = door.voxel_pos
	if voxel == voxels[1]:
		door.rotation.y = PI / -2.0
		door.position.x += 1
	door.get_node("Animator").play("open")

