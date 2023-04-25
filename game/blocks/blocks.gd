# Container for all block types.
# It is not a resource because it references scripts that can depend on it,
# causing cycles. So instead, it's more convenient to make it a node in the tree.
# IMPORTANT: Needs to be first in tree. Other nodes may use it in _ready().
extends Node

const Block = preload("./block.gd")

class RawMapping:
	var block_id := 0
	var variant_index := 0


var _voxel_library := preload("res://game/blocks/voxel_library.tres")
var _blocks = []
var _raw_mappings = []

var AIR
var WATER
var SOIL
var STONE
var SAND
var METAL
var LIGHT
var DOOR
var GLASS
var WALKWAY
var TILES


func _init():
	AIR = _create_block({
		"name": "air",
		"voxels": ["air"],
	})
	WATER = _create_block({
		"name": "water",
		"voxels": ["water"],
		"tags": ["gravity", "liquid"],
	})
	SOIL = _create_block({
		"name": "soil",
		"voxels": ["soil"],
	})
	STONE = _create_block({
		"name": "stone",
		"voxels": ["stone"],
	})
	SAND = _create_block({
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
	GLASS = _create_block({
		"name": "glass",
		"voxels": ["glass"],
	})
	_create_block({
		"name": "slab",
		"voxels": ["slab"],
	})
	_create_block({
		"name": "door",
		"voxels": ["door_ew","door_ns"],
		"placement": Block.ROT2,
		"script": "doors/door"
	})
	_create_block({
		"name": "square light",
		"voxels": ["square light"],
		"script": "lights/light"
	})
	METAL = _create_block({
		"name": "metal",
		"voxels": ["metal"],
	})
	WALKWAY = _create_block({
		"name": "walkway",
		"voxels": ["walkway"],
	})
	TILES = _create_block({
		"name": "tiles",
		"voxels": ["tiles"],
	})
	_create_block({
		"name": "table",
		"voxels": ["table"],
	})
	_create_block({
		"name": "chair",
		"voxels": ["chair"],
	})
	_create_block({
		"name": "locker",
		"voxels": ["locker"],
		"script": "containers/locker"
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


func get_block_by_voxel(raw_id: int):
	var rm = get_raw_mapping(raw_id)
	return get_block(rm.block_id)


# Gets the corresponding block ID and variant index from a raw voxel value
func get_raw_mapping(raw_id: int) -> RawMapping:
	assert(raw_id >= 0)
	var rm = _raw_mappings[raw_id]
	assert(rm != null)
	return rm


func get_block_count() -> int:
	return len(_blocks)


func _create_block(params: Dictionary):
	var block : Block
	var script = params.get("script")
	if script != null:
		# Block with special behavior
		var behavior_path := str("res://game/blocks", "/", script + ".gd")
		var behavior = load(behavior_path)
		block = behavior.new()
		block.custom = true
	else:
		# Generic
		block = Block.new()

	block.id = len(_blocks)
	
	var r
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
		r = id

	block.sid = params.name
	block.placement = params.get("placement", Block.NORMAL)
	block.tags = params.get("tags", [])
	block.voxels = params.voxels

	_blocks.append(block)
	add_child(block)
	return r


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			print("Deleting blocks.gd")
