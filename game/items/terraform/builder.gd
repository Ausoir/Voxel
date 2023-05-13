extends "./paver.gd"

const Prefab_JSON = preload("res://assets/json/prefabs.json")

var _cursor_size := Vector3(0, .5, 0)


func use(_user: Node3D):
	_set_default_block()
	var hit = get_pointed_block(_user)
	if hit != null and _chosen_buildable != null:
		var pos = hit.previous_position
		if G.tool.collide_prop_by_shape(pos, .7, 2).size() == 0:
			if _chosen_buildable[1] == 0:
				_cancel_build()
				_attempt_prefab(pos, _chosen_buildable[0], _user.forward)
			else:
				if _start_cursor == null:
					_start_build(_user, pos)
				elif _chosen_buildable[1] == 1:
					_end_build(_user, pos, true)
				elif _chosen_buildable[1] == 2:
					_end_build(_user, pos)
		else:
			print("Can't place here!")
		_user.action.set_next("idle", .1)


func use2(_user: Node3D):
	_cancel_build()
	var multiselect = MULTISELECT.instantiate()
	for i in data.get("buildables", []):
		multiselect.add_button(i[0].capitalize(), Callable(self, "_choose_block").bind(i))
	G.ui.display(multiselect)


func _choose_block(buildable):
	_chosen_buildable = buildable
	_cursor.scale = Vector3(buildable[2][0], buildable[2][1], buildable[2][2])
	_cursor_size.y = _cursor.scale.y / 2
	offset = buildable[3]


func on_held_tick(_user: Node3D):
	var hit = get_pointed_block(_user)
	if hit != null:
		_cursor.position = Vector3(hit.previous_position) + G.V2_HALF + _cursor_size
		var dir = Vector2(_user.forward.x, _user.forward.z)
		_cursor.rotation.y = (G.tool.Util.get_direction_id4(Vector2(dir.x, dir.y)) + 1) * (PI/2.0)


func _attempt_prefab(_pos: Vector3, _prefab: String, _look_dir: Vector3):
	var dict = Prefab_JSON.get_data()
	var dat = dict.get(_prefab)
	if dat != null:
		var hwidth: int = dat[0][0].length() / 2
		var hheight: int = dat[0].size() / 2
		var left = _pos - Vector3(hwidth, 0, hheight)
		var right = _pos + Vector3(hwidth, dat.size()-1, hheight)
		if !G.tool.check_box(left, right):
			return false
		var current_floor = offset
		for story in dat:
			var vault = rotate_vault(story, _look_dir)
			for row in range(vault.size()):
				for cell in range(vault[row].length()):
					var icon = vault[row][cell]
					var block = G.blocks.get_block_by_icon(icon)
					if block != null:
						var pos = Vector3(left.x + cell, _pos.y + current_floor, left.z + row)
						var site = G.blocks.get_block_by_name("build site")
						site.t_metadata = block.sid
						G.tool.set_block(pos, site.id, Vector3.UP)
						if current_floor != 0:
							G.tool.set_voxel(pos, 0)
			current_floor += 1


func rotate_vault(vault, look_dir):
	var rotvault = []
	var sx = vault[0].length()
	var sy = vault.size()
	var dir = G.tool.get_y_rotation_from_look_dir(look_dir)
	if dir == 3:
		for x in range(sx):
			var nrow = ""
			for y in range(sy):
				nrow += vault[sy-y-1][x]
			rotvault.append(nrow)
	elif dir == 0:
		for y in range(sy):
			var nrow = ""
			for x in range(sx):
				nrow += vault[sy-y-1][sx-x-1]
			rotvault.append(nrow)
	elif dir == 1:
		for x in range(sx):
			var nrow = ""
			for y in range(sy):
				nrow += vault[y][sx-x-1]
			rotvault.append(nrow)
	elif dir == 2:
		return vault
	return rotvault

