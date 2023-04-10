extends "../item.gd"

@onready var _block_types = get_node("/root/Game/Blocks")
@onready var _water_updater = get_node("../../Water")


func use(_user: Node3D, _trans: Transform3D):
	var hit = get_pointed_voxel(_user)
	if hit != null:
#			_cursor.show()
#			_cursor.set_position(hit.position)
		DDD.set_text("Pointed voxel", str(hit.position))
		var hit_raw_id = tool.get_voxel(hit.position)
		var has_cube = hit_raw_id != 0
		
		if Input.is_action_just_pressed("use") and has_cube:
			var pos = hit.position
			_place_single_block(pos, 0)
		
		elif Input.is_action_just_pressed("interact"):
			var pos = hit.previous_position
			var rm = _block_types.get_block(hit_raw_id)
			DDD.set_text("Pointed to", rm.name)
			if has_cube == false:
				pos = hit.position
			if _can_place_voxel_at(pos):
				if inv_item != null:
					_place_single_block(_user, pos, inv_item.id)
					print("Place voxel at ", pos)
			else:
				print("Can't place here!")
	else:
#			_cursor.hide()
		DDD.set_text("Pointed voxel", "---")


func _place_single_voxel(pos: Vector3, type: int):
	tool.value = type
	tool.do_point(pos)


func _can_place_voxel_at(pos: Vector3):
	# TODO Is it really relevant anymore? This demo doesn't use physics	
	var space_state = get_viewport().get_world_3d().get_direct_space_state()
	var params = PhysicsShapeQueryParameters3D.new()
	params.collision_mask = COLLISION_LAYER_AVATAR
	params.transform = Transform3D(Basis(), pos + Vector3(1,1,1)*0.5)
	var shape = BoxShape3D.new()
	var ex = 0.5
	shape.size = Vector3(ex, ex, ex)
	params.set_shape(shape)
	var hits = space_state.intersect_shape(params)
	return hits.size() == 0


func _place_single_block(_user, pos: Vector3, block_id: int):
	var block = _block_types.get_block(block_id)
	var voxel_id := 0
	var look_dir = _user.forward

	if "axial" in block.tags:
		var axis := Util.get_longest_axis(look_dir)
		voxel_id = block.voxels[axis]
		_place_single_voxel(pos, voxel_id)
	elif "yrot" in block.tags:
		var rot := Blocks.get_y_rotation_from_look_dir(look_dir)
		voxel_id = block.voxels[rot]
		_place_single_voxel(pos, voxel_id)
	elif "custom" in block.tags:
		block.place(tool, pos, look_dir)
	else:
		voxel_id = block.voxels[0]
		_place_single_voxel(pos, voxel_id)

	_water_updater.schedule(pos)
