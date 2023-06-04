extends "../block.gd"

const INTERFACE = preload("res://game/ui/menus/stash.tscn")
var _menu


func on_place(_pos: Vector3):
	G.tool.get_tool().set_voxel_metadata(_pos, "Open Chest123")
	G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
	var v = int(G.vars.seed + _pos.x + _pos.z + _pos.y)
	G.tool.set_voxel(_pos, v % 16)
	G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)


func on_hover(_pos: Vector3):
	G.ui.set_label("Open Chest")


func on_interact(_pos: Vector3, _user: Node3D):
	_user.action.set_next("enter", data.get("time", 1), on_activate.bind(_pos, _user))
	_user.action.show_progress = true
	_user.action.cancelable = true


func on_activate(_pos: Vector3, _user: Node3D):
	G.sfx.play("door_creak", _pos)
	if _menu == null:
		_menu = INTERFACE.instantiate()
	G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
	var inside = G.tool.get_voxel(_pos)
	G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
	seed(int((G.vars.seed - _pos.x - _pos.z) * _pos.y))
	var items = []
	var bit = 1
	for i in range(4):
		if inside & bit > 0:
			var loot_type = data.get("loot", "treasure")
			var itemname = G.stock.make_group(G.mapdata.get(loot_type), randf())
			if itemname != null:
				items.append(itemname)
		bit = bit << 1
	_menu.placeable = false
	_menu.load_stash = items
	_menu.on_set = on_set.bind(_pos)
	G.ui.display(_menu)


func on_set(idx, itemname, _pos):
	if itemname == null:
		var bit = 1 << idx
		G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
		var v = G.tool.get_voxel(_pos)
		G.tool.set_voxel(_pos, v - bit)
		G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
