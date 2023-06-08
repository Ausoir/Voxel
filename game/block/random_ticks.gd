# Implements random cellular automata behavior of the terrain,
# such as growth of grass and crops, fire etc.

extends Node

const VoxelLibraryResource = preload("./voxel_library.tres")

const RANGE = Vector3(32, 8, 32)
const VOXELS_PER_FRAME = 512

@onready var _blocks = get_node("../Blocks")
@onready var _avatar = get_node("../Player")
@onready var _terrain = get_node("../Terrain")
@onready var _voxel_tool = _terrain.get_voxel_tool()

var _light_type : int
var _fn_random_tick = Callable(self, "_random_tick_callback")


func _ready():
	_light_type = VoxelLibraryResource.get_voxel_index_from_name("square light")
	_voxel_tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
	set_process(false)


func _process(_delta):
	var center = G.you.transform.origin.floor()
	var area = AABB(center - RANGE, 2 * RANGE)
	_voxel_tool.run_blocky_random_tick(
		area, VOXELS_PER_FRAME, _fn_random_tick, 16)
	#var time_spent = OS.get_ticks_usec() - time_before
	#print("Spent ", time_spent)


func _random_tick_callback(pos: Vector3, value: int):
	if value == 131111:
		_voxel_tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
		var val = _voxel_tool.get_voxel(pos)
		if G.switch != val:
			var light = _blocks.get_block_by_voxel(value)
			light.lit(_voxel_tool, pos)
			_voxel_tool.set_voxel_metadata(pos, 'L')
		_voxel_tool.set_channel(VoxelBuffer.CHANNEL_TYPE)

