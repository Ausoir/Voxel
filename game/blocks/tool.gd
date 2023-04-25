extends Node


const Util = preload("res://tools/util.gd")

const ROTATION_Y_NEGATIVE_X = 0
const ROTATION_Y_POSITIVE_X = 1
const ROTATION_Y_NEGATIVE_Z = 2
const ROTATION_Y_POSITIVE_Z = 3

@onready var _tool = get_node("../Terrain").get_voxel_tool()
@onready var _blocks = get_node("../Blocks")

var load_props = []


func _process(_delta):
	var next = load_props.pop_front()
	if next != null:
		var pos = next[0]
		var block_id = next[1]
		var view = next[2]
		place_block(pos, block_id, view)
	else:
		set_process(false)


func add_prop(prop):
	load_props.append(prop)
	set_process(true)


func get_block(pos: Vector3):
	var hit_raw_id = _tool.get_voxel(pos)
	return _blocks.get_block_by_voxel(hit_raw_id)


func raycast(origin: Vector3, toward: Vector3, distance: float):
	return _tool.raycast(origin, toward, distance)


func remove_block(pos: Vector3):
	var hit_raw_id = _tool.get_voxel(pos)
	if hit_raw_id != 0:
		var block = _blocks.get_block_by_voxel(hit_raw_id)
		block.remove(pos)
		_tool.value = 0
		_tool.do_point(pos)


func place_block(pos: Vector3, block_id: int, look_dir: Vector3):
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

	place_voxel(pos, voxel_id)

	if block.custom:
		block.on_place(pos)


func place_voxel(pos, voxel_id):
	_tool.value = voxel_id
	_tool.do_point(pos)


func get_voxel(pos: Vector3):
	return _tool.get_voxel(pos)


func collide_prop_by_shape(pos: Vector3, size: int, col: int):
	var space_state = get_viewport().get_world_3d().get_direct_space_state()
	var params = PhysicsShapeQueryParameters3D.new()
	params.collision_mask = col
	params.transform = Transform3D(Basis(), pos + Vector3(size, size, size) * .5)
	var shape = BoxShape3D.new()
	shape.size = Vector3(size, size, size)
	params.set_shape(shape)
	return space_state.intersect_shape(params)


func collide_prop_by_point(pos: Vector3, col: int):
	var space_state = get_viewport().get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = pos
	params.to = pos
	params.collision_mask = col
	params.set_collide_with_bodies(true)
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
