extends Node

const Block = preload("./block.gd")
const Library := preload("res://game/blocks/voxel_library.tres")
const Block_JSON := preload("res://assets/json/blocks.json")

class RawMapping:
	var block_id := 0
	var variant_index := 0


var _blocks = []
var _raw_mappings = []

var VOID
var MARKER
var SPAWNER
var STONE
var SAND
var SOIL
var METAL
var GLASS
var WALKWAY
var TILES


func _init():
	var dict = Block_JSON.get_data()
	for blockname in dict.keys():
		var block = dict[blockname]
		var r = _create_block(blockname, block)
		set(blockname.to_upper(), r)


func get_block(id: int) -> Block:
	assert(id >= 0)
	return _blocks[id]


func get_block_by_name(block_name: String) -> Block:
	for b in _blocks:
		if b.sid == block_name:
			return b
	assert(false)
	return null


func get_block_by_voxel(raw_id: int):
	var rm = get_raw_mapping(raw_id)
	return get_block(rm.block_id)



func get_block_by_icon(icon):
	for b in _blocks:
		if b.icon == icon:
			return b
	return null


func get_raw_mapping(raw_id: int) -> RawMapping:
	assert(raw_id >= 0)
	var rm = _raw_mappings[raw_id]
	assert(rm != null)
	return rm


func get_block_count() -> int:
	return len(_blocks)


func _create_block(blockname: String, params: Dictionary):
	var block : Block
	var script = params.get("script")
	if script != null:
		# Block with special behavior
		var behavior_path := str("res://game/blocks/", script, ".gd")
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
		var id = Library.get_voxel_index_from_name(vname)
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

	block.sid = blockname
	block.icon = params.get("icon")
	block.placement = params.get("placement", Block.NORMAL)
	block.tickable = params.get("tickable", false)
	block.tags = params.get("tags", [])
	block.data = params.get("data", {})
	block.voxels = params.voxels

	_blocks.append(block)
	add_child(block)
	return r


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			print("Deleting blocks.gd")
