extends "../block.gd"

const Door = preload("res://game/block/doors/prop_shutter.tscn")
var callback = Callable(self, "on_activate")
var door


func on_hover(_pos):
	var meta = G.tool.get_tool().get_voxel_metadata(_pos)
	if meta != null:
		G.ui.set_label("Open Shutter")
		return true


func on_place(_pos: Vector3):
	var above = _pos + Vector3.UP
	var current_voxel = G.tool.get_voxel(_pos)
	G.tool.set_voxel(above, current_voxel)
	var meta = "Open Shutters"
	G.tool.get_tool().set_voxel_metadata(_pos, meta)
	G.tool.get_tool().set_voxel_metadata(above, meta)


func on_remove(_pos: Vector3):
	var above = _pos + Vector3.UP
	G.tool.get_tool().set_voxel_metadata(_pos, null)
	G.tool.get_tool().set_voxel_metadata(above, null)
	if door != null:
		G.stock.remove_child(door)
		door.queue_free()
		door = null


func on_interact(_pos: Vector3, _user: Node3D):
	_user.action.set_next("use", 2, callback.bind(_pos, _user))
	_user.action.show_progress = true
	_user.action.cancelable = true
	_user.action.turnable = false
	return true


func on_activate(_pos: Vector3, _user: Node3D):
	_user.action.set_next("idle", 0)
	var exc = link(_pos, [])
	for i in exc:
		open(i, _user)


func open(_pos: Vector3, _user: Node3D):
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
	door.on_activate(_user)


func link(_pos: Vector3, exc):
	exc.append(_pos)
	for i in G.CARDINALS:
		var neighbor = _pos + i
		if G.tool.get_voxel(neighbor) in voxels and !(neighbor in exc):
			link(neighbor, exc)
	return exc
