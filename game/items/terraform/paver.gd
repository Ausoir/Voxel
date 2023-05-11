extends "./placer.gd"

var offset = 0
var _start_cursor
var _start_pos


func use(_user: Node3D):
	_set_default_block()
	var hit = get_pointed_block(_user)
	if hit != null:
		var pos = hit.previous_position
		if G.tool.collide_prop_by_shape(pos, .7, 2).size() == 0:
			if _start_cursor == null:
				_start_build(_user, pos)
			else:
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


func _start_build(_user, _pos: Vector3i):
	_cancel_build()
	_start_cursor = SELECTION.instantiate()
	_blocks.add_child(_start_cursor)
	_start_cursor.position = Vector3(_pos) + G.V2_HALF
	_start_pos = _pos


func _end_build(_user, _pos: Vector3i, hollow=false):
	if G.tool.check_box(_start_pos, _pos):
		var site = G.blocks.get_block_by_name("build site")
		site.t_metadata = _chosen_buildable[0]
		if offset != 0:
			G.tool.do_box(_start_pos, _pos, site.voxels[0], hollow)
			var offset_start_pos = _start_pos + Vector3i(0, offset, 0)
			var offset_pos = _pos + Vector3i(0, offset, 0)
			G.tool.block_box(offset_start_pos, offset_pos, site.id, hollow)
		else:
			G.tool.block_box(_start_pos, _pos, site.id, hollow)
	_cancel_build()


func _cancel_build():
	if _start_cursor != null:
		_start_cursor.queue_free()
		_start_cursor = null


func _choose_block(buildable):
	_chosen_buildable = buildable
	_cursor.scale = Vector3(buildable[2][0], buildable[2][1], buildable[2][2])


func on_unheld(_user: Node3D):
	_cancel_build()
	_blocks.remove_child(_cursor)

