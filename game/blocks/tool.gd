extends Node

const Util = preload("res://tools/util.gd")

const _CHANNEL_TYPE = VoxelBuffer.CHANNEL_TYPE
const ROTATION_Y_POSITIVE_Z = 0
const ROTATION_Y_NEGATIVE_X = 1
const ROTATION_Y_NEGATIVE_Z = 2
const ROTATION_Y_POSITIVE_X = 3

@onready var _tool = get_node("../Terrain").get_voxel_tool()
@onready var _blocks = get_node("../Blocks")


func get_block(pos: Vector3):
	var hit_raw_id = _tool.get_voxel(pos)
	return _blocks.get_block_by_voxel(hit_raw_id)


func check_box(start: Vector3i, end: Vector3i):
	for x in range(min(start.x, end.x), max(start.x, end.x) + 1):
		for y in range(min(start.y, end.y), max(start.y, end.y) + 1):
			for z in range(min(start.z, end.z), max(start.z, end.z) + 1):
				if _tool.get_voxel(Vector3(x, y, z)) != 0:
					return false
	return true


func raycast(origin: Vector3, toward: Vector3, distance: float, col=12) -> VoxelRaycastResult:
	return _tool.raycast(origin, toward, distance, col)


func remove_block(pos: Vector3):
	var hit_raw_id = _tool.get_voxel(pos)
	if hit_raw_id != 0:
		var block = _blocks.get_block_by_voxel(hit_raw_id)
		_tool.value = 0
		_tool.do_point(pos)
		block.on_remove(pos)


func set_block_by_name(pos: Vector3, block_name: String, look_dir: Vector3):
	var block = _blocks.get_block_by_name(block_name)
	set_block(pos, block.id, look_dir)


func set_block(pos: Vector3, block_id: int, look_dir: Vector3):
	var block = _blocks.get_block(block_id)
	var voxel_id := 0
	
	if block.placement == block.NORMAL:
		voxel_id = block.voxels[0]
	elif block.placement == block.CUSTOM:
		block.place(_tool, pos, look_dir)
	elif block.placement == block.ROT2:
		var rot = get_y_rotation_from_look_dir(look_dir)
		voxel_id = block.voxels[int(rot/2)]
	elif block.placement == block.ROT4:
		var rot = get_y_rotation_from_look_dir(look_dir)
		voxel_id = block.voxels[rot]
	elif block.placement == block.AXIAL:
		var axis := Util.get_longest_axis(look_dir)
		voxel_id = block.voxels[axis]

	if block.tickable:
		G.turn.add(Callable(block, "on_tick").bind(pos))
	set_voxel(pos, voxel_id)

	if block.custom:
		block.on_place(pos)


func block_sphere(pos, r, block_id):
	var r_squared = (r - 2) * (r - 2)
	for tx in range(-r, r):
		var tx_squared = tx * tx
		for ty in range(-r, r):
			var ty_squared = ty * ty
			for tz in range(-r, r):
				var tz_squared = tz * tz
				if (tx_squared + ty_squared + tz_squared) <= r_squared:
					set_block(pos + Vector3i(tx, ty, tz), block_id, Vector3i.UP)


func block_box(pos, to, block_id, hollow=false):
	var dx = abs(pos.x - to.x)
	var dz = abs(pos.z - to.z)
	for x in range(dx+1):
		for z in range(dz+1):
			var mx = min(pos.x, to.x)
			var mz = min(pos.z, to.z)
			var tx = mx + x
			var tz = mz + z
			if hollow:
				if (tx == mx or tx == mx+dx) or (tz == mz or tz == mz+dz):
					set_block(Vector3i(tx, pos.y, tz), block_id, Vector3i.UP)
			else:
				set_block(Vector3i(tx, pos.y, tz), block_id, Vector3i.UP)


func set_voxel(pos, voxel_id):
	_tool.value = voxel_id
	_tool.do_point(pos)


func do_box(pos, to, voxel_id, hollow=false):
	if !hollow:
		_tool.value = voxel_id
		_tool.do_box(pos, to)
	else:
		var dx = abs(pos.x - to.x)
		var dz = abs(pos.z - to.z)
		for x in range(dx+1):
			for z in range(dz+1):
				var mx = min(pos.x, to.x)
				var mz = min(pos.z, to.z)
				var tx = mx + x
				var tz = mz + z
				if hollow:
					if (tx == mx or tx == mx+dx) or (tz == mz or tz == mz+dz):
						set_voxel(Vector3i(tx, pos.y, tz), voxel_id)
				else:
					set_voxel(Vector3i(tx, pos.y, tz), voxel_id)


func get_voxel(pos: Vector3):
	return _tool.get_voxel(pos)


func set_channel(channel):
	_tool.set_channel(channel)


func get_tool():
	return _tool


func collide_prop_by_shape(pos: Vector3, size: int, col: int = 12):
	var space_state = get_viewport().get_world_3d().get_direct_space_state()
	var params = PhysicsShapeQueryParameters3D.new()
	params.collision_mask = col
	params.transform = Transform3D(Basis(), pos + Vector3(size, size, size) * .5)
	var shape = BoxShape3D.new()
	shape.size = Vector3(size, size, size)
	params.set_collide_with_areas(true)
	params.set_shape(shape)
	return space_state.intersect_shape(params)


func collide_prop_by_line(pos: Vector3, to: Vector3, col: int = 12):
	var space_state = get_viewport().get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = pos
	params.to = to
	params.collision_mask = col
	params.set_collide_with_areas(true)
	return space_state.intersect_ray(params)


static func get_y_rotation_from_look_dir(dir: Vector3) -> int:
	var a = Util.get_direction_id4(Vector2(dir.x, dir.z))
	match a:
		0:
			return ROTATION_Y_NEGATIVE_X
		1:
			return ROTATION_Y_NEGATIVE_Z
		2:
			return ROTATION_Y_POSITIVE_X
		3:
			return ROTATION_Y_POSITIVE_Z
		_:
			assert(false)
	return -1
