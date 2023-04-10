# Container for all block types.
# It is not a resource because it references scripts that can depend on it,
# causing cycles. So instead, it's more convenient to make it a node in the tree.
# IMPORTANT: Needs to be first in tree. Other nodes may use it in _ready().
extends Node

const Block = preload("./block.gd")
const Util = preload("res://tools/util.gd")

const ROTATION_Y_NEGATIVE_X = 0
const ROTATION_Y_POSITIVE_X = 1
const ROTATION_Y_NEGATIVE_Z = 2
const ROTATION_Y_POSITIVE_Z = 3

const _opposite_y_rotation = [
	ROTATION_Y_POSITIVE_X,
	ROTATION_Y_NEGATIVE_X,
	ROTATION_Y_POSITIVE_Z,
	ROTATION_Y_NEGATIVE_Z
]

const _y_dir = [
	Vector3(-1, 0, 0),
	Vector3(1, 0, 0),
	Vector3(0, 0, -1),
	Vector3(0, 0, 1)
]

const ROOT = "res://game/blocks"

const AIR_ID = 0

class RawMapping:
	var block_id := 0
	var variant_index := 0


var _voxel_library := preload("res://game/blocks/voxel_library.tres")
var _blocks = []
var _raw_mappings = []


func _init():
	print("Constructing blocks.gd")
	_create_block({
		"name": "air",
		"voxels": ["air"],
	})
	_create_block({
		"name": "water",
		"voxels": ["water"],
		"tags": ["gravity", "liquid"],
	})
	_create_block({
		"name": "soil",
		"voxels": ["soil"],
	})
	_create_block({
		"name": "stone",
		"voxels": ["stone"],
	})
	_create_block({
		"name": "sand",
		"voxels": ["sand"],
	})
	_create_block({
		"name": "log",
		"voxels": ["log"],
		"tags": ["gravity"],
	})
	_create_block({
		"name": "leaves",
		"voxels": ["leaf"],
	})
	_create_block({
		"name": "white light",
		"voxels": ["white light"],
	})


func get_block(id: int) -> Block:
	assert(id >= 0)
	return _blocks[id]


func get_model_library() -> VoxelBlockyLibrary:
	return _voxel_library


func get_block_by_name(block_name: String) -> Block:
	for b in _blocks:
		if b.sid == block_name:
			return b
	assert(false)
	return null


# Gets the corresponding block ID and variant index from a raw voxel value
func get_raw_mapping(raw_id: int) -> RawMapping:
	assert(raw_id >= 0)
	var rm = _raw_mappings[raw_id]
	assert(rm != null)
	return rm


func get_block_count() -> int:
	return len(_blocks)


func _create_block(params: Dictionary):
	_defaults(params, {
		"tags": [],
		"spritename": "placer",
		"modelname": "placer",
		"behavior": ""
	})

	var block : Block
	if params.behavior != "":
		# Block with special behavior
		var behavior_path := str(ROOT, "/", params.directory, "/", params.behavior)
		var behavior = load(behavior_path)
		block = behavior.new()
	else:
		# Generic
		block = Block.new()

	block.id = len(_blocks)
	
	for i in len(params.voxels):
		var vname = params.voxels[i]
		var id = _voxel_library.get_voxel_index_from_name(vname)
		if id == -1:
			push_error("Could not find voxel named {0}".format([vname]))
		assert(id != -1)
		params.voxels[i] = id
		var rm = RawMapping.new()
		rm.block_id = block.id
		rm.variant_index = i
		if id >= len(_raw_mappings):
			_raw_mappings.resize(id + 1)
		_raw_mappings[id] = rm

	block.sid = params.name
	block.tags = params.tags
	block.voxels = params.voxels
	block.sprite = load("res://assets/items/" + params.spritename + ".png")
	block.model = load("res://assets/items/" + params.modelname + ".obj")

	_blocks.append(block)
	add_child(block)


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			print("Deleting blocks.gd")


static func _defaults(d, defaults):
	for k in defaults:
		if not d.has(k):
			d[k] = defaults[k]


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


static func get_y_dir_vec(yid: int) -> Vector3:
	return _y_dir[yid]


static func get_opposite_y_dir(yid: int) -> int:
	return _opposite_y_rotation[yid]
