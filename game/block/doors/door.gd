extends "../block.gd"

const Door = preload("res://game/block/doors/prop_door.tscn")
var callback = Callable(self, "on_activate")
var door


func on_hover(_pos):
	var meta = G.tool.get_tool().get_voxel_metadata(_pos)
	if meta != null:
		G.ui.set_label("Open Door")
		return true


func on_place(_pos: Vector3):
	var above = _pos + Vector3.UP
	var current_voxel = G.tool.get_voxel(_pos)
	var current_id = voxels.find(current_voxel)
	G.tool.set_voxel(above, voxels[current_id + 2])
	var meta = "Open Door"
	G.tool.get_tool().set_voxel_metadata(_pos, meta)
	G.tool.get_tool().set_voxel_metadata(above, meta)


func on_remove(_pos: Vector3):
	var above = _pos + Vector3.UP
	G.tool.get_tool().set_voxel_metadata(_pos, null)
	G.tool.get_tool().set_voxel_metadata(above, null)
	G.tool.set_voxel(above, 0)
	if door != null:
		G.stock.remove_child(door)
		door.queue_free()
		door = null


func on_interact(_pos: Vector3, _user: Node3D):
	_user.action.set_next("use", 1, callback.bind(_pos, _user))
	_user.action.show_progress = true
	_user.action.cancelable = true
	_user.action.turnable = false
	return true


func on_activate(_pos: Vector3, _user: Node3D):
	_user.action.set_next("idle", 0)
	var voxel = G.tool.get_voxel(_pos)
	door = Door.instantiate()
	if voxel == voxels[2] or voxel == voxels[3]:
		door.voxel_ids = [voxel - 2, voxel]
		door.voxel_pos = _pos + Vector3.DOWN
		G.tool.set_voxel(_pos + Vector3.DOWN, 0)
	else:
		door.voxel_ids = [voxel, voxel + 2]
		door.voxel_pos = _pos
		G.tool.set_voxel(_pos + Vector3.UP, 0)
	G.tool.set_voxel(_pos, 0)
	G.stock.add_child(door)
	door.position = door.voxel_pos
	if voxel == voxels[1] or voxel == voxels[3]:
		door.rotation.y = PI / -2.0
		door.position.x += 1
	door.get_node("Animator").play("open2")
	G.sfx.play("door_open", door.position)
	G.tool.set_sound(door.position, 3)
