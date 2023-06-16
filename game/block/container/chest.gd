extends "../block.gd"

const INTERFACE = preload("res://game/ui/menus/stash.tscn")
const Chest = preload("res://game/block/container/chest.tscn")


func on_place(_pos: Vector3):
	G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
	var v = int(G.vars.seed * G.vars.day + sin(_pos.x)*12435 + cos(_pos.z)*412331 + _pos.y)
	G.tool.set_voxel(_pos, v % 16)
	G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)


func on_hover(_pos: Vector3):
	G.ui.set_label("Open Container")


func on_interact(_pos: Vector3, _user: Node3D):
	_user.action.set_next("enter", data.get("time", 1), on_activate.bind(_pos, _user))
	_user.action.show_progress = true
	_user.action.cancelable = true
	return true


func on_activate(_pos: Vector3, _user: Node3D):
	var has_opened = G.tool.get_voxel(_pos) == voxels[1]
	if !has_opened:
		G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
		var inside = G.tool.get_voxel(_pos)
		G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
		if inside == 0:
			G.stock.make_unit(_pos + G.V2_HALF, "mimic")
			G.tool.remove_block(_pos)
			return
	on_open(_pos, _user, has_opened)


func on_open(_pos: Vector3, _user: Node3D, has_opened):
	var _menu = INTERFACE.instantiate()
	G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
	var inside = G.tool.get_voxel(_pos)
	G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
	var v = int(G.vars.seed * G.vars.day + sin(_pos.x)*12435 + cos(_pos.z)*412331 + _pos.y)
	var items = []
	var bit = 1
	for i in range(4):
		var itemname
		if inside & bit > 0:
			G.rng.set_seed(v * i)
			var loot_type = data.get("loot", "treasure")
			itemname = G.stock.make_group(G.mapdata.get(loot_type))
		items.append(itemname)
		bit = bit << 1
	_menu.placeable = false
	_menu.load_stash = items
	_menu.on_set = on_set.bind(_pos)
	G.ui.display(_menu)
	if !has_opened:
		G.sfx.play("door_creak", _pos)
		var prop = Chest.instantiate()
		prop.position = _pos
		G.stock.add_child(prop)
		prop.get_node("Animator").play("open")
		G.tool.set_sound(prop.position, 3)
	G.tool.set_voxel(_pos, voxels[1])


func on_set(idx, itemname, _pos):
	if itemname == null:
		var bit = 1 << idx
		G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
		var v = G.tool.get_voxel(_pos)
		G.tool.set_voxel(_pos, v - bit)
		G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
