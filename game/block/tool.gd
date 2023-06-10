extends Node

const _CHANNEL_TYPE = VoxelBuffer.CHANNEL_TYPE

@onready var _tool = get_node("../Terrain").get_voxel_tool()
@onready var _blocks = get_node("../Blocks")


func _ready():
	_tool.mode = VoxelTool.MODE_SET


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
		if block != null:
			block.on_remove(pos)
		_tool.value = 0
		_tool.do_point(pos)


func set_block_by_name(pos: Vector3, block_name: String, look_dir: Vector3):
	var block = _blocks.get_block_by_name(block_name)
	set_block(pos, block.id, look_dir)


func set_block(pos: Vector3, block_id: int, look_dir):
	var block = _blocks.get_block(block_id)
	var voxel_id := 0
	
	if block.placement == block.NORMAL:
		voxel_id = block.voxels[0]
	else:
		if look_dir == null:
			look_dir = _get_marker_look_dir(pos)
		if block.placement == block.CUSTOM:
			block.place(pos, look_dir)
		elif block.placement == block.ROT2:
			var rot = _get_y_rotation_from_look_dir(look_dir)
			voxel_id = block.voxels[rot % 2]
		elif block.placement == block.ROT4:
			var rot = _get_y_rotation_from_look_dir(look_dir)
			voxel_id = block.voxels[rot]
		elif block.placement == block.AXIAL:
			var axis := _get_longest_axis(look_dir)
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


func block_spawn(pos, to):
	var dx = abs(pos.x - to.x)
	var dy = abs(pos.y - to.y)
	var dz = abs(pos.z - to.z)
	for x in range(dx+1):
		for y in range(dy+1):
			for z in range(dz+1):
				var mx = min(pos.x, to.x)
				var my = min(pos.y, to.y)
				var mz = min(pos.z, to.z)
				var tx = mx + x
				var ty = my + y
				var tz = mz + z
				var at = Vector3i(tx, ty, tz)
				if _tool.get_voxel(at) < 2:
					set_voxel(at, 4)


func set_sound(pos, radius):
	_tool.set_channel(VoxelBuffer.CHANNEL_DATA6)
	var vrad = Vector3(radius, radius, radius)
	_tool.value = G.sec
	_tool.do_box(pos - vrad, pos + vrad)
	_tool.set_channel(_CHANNEL_TYPE)


func get_sound(pos):
	_tool.set_channel(VoxelBuffer.CHANNEL_DATA6)
	var r = _tool.get_voxel(pos)
	_tool.set_channel(_CHANNEL_TYPE)
	return r == G.sec


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


func draw_line_3d(a: Vector3, b: Vector3, color: Color):
	var g = ImmediateMesh.new()
	g.begin(Mesh.PRIMITIVE_LINES)
	g.set_color(color)
	g.add_vertex(a)
	g.add_vertex(b)
	g.end()
	add_child(g)


func get_rotation_from_marker(pos: Vector3):
	var look_dir = _get_marker_look_dir(pos)
	var yrot = _get_y_rotation_from_look_dir(look_dir)
	return yrot


func _get_marker_look_dir(pos: Vector3):
	if get_voxel(pos + Vector3.LEFT) == 2:
		return Vector3.LEFT
	elif get_voxel(pos + Vector3.RIGHT) == 2:
		return Vector3.RIGHT
	elif get_voxel(pos + Vector3.FORWARD) == 2:
		return Vector3.FORWARD
	elif get_voxel(pos + Vector3.BACK) == 2:
		return Vector3.BACK
	return Vector3.UP


func _get_y_rotation_from_look_dir(dir: Vector3) -> int:
	var a = int(4.0 * (Vector2(dir.x, dir.z).rotated(PI / 4.0).angle() + PI) / TAU)
	match a:
		0:
			return 3#ROTATION_Y_POSITIVE_X
		1:
			return 2#ROTATION_Y_NEGATIVE_Z
		2:
			return 1#ROTATION_Y_NEGATIVE_X
		3:
			return 0#ROTATION_Y_POSITIVE_Z
		_:
			assert(false)
	return -1


func _get_longest_axis(v: Vector3) -> int:
	var lx = abs(v.x)
	var ly = abs(v.y)
	var lz = abs(v.z)
	if lx > ly and lx > lz:
		return Vector3.AXIS_X
	if ly > lx and ly > lz:
		return Vector3.AXIS_Y
	return Vector3.AXIS_Z


func cardinalize(v: Vector3):
	var longest = _get_longest_axis(v)
	if longest == Vector3.AXIS_X:
		if v.x > 0:
			return Vector3(1, 0, 0)
		else:
			return Vector3(-1, 0, 0)
	elif longest == Vector3.AXIS_Y:
		if v.y > 0:
			return Vector3(0, 1, 0)
		else:
			return Vector3(0, -1, 0)
	elif longest == Vector3.AXIS_Z:
		if v.z > 0:
			return Vector3(0, 0, 1)
		else:
			return Vector3(0, 0, -1)
