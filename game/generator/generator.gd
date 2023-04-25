extends VoxelGeneratorScript

const Structure = preload("./structure.gd")
const TreeGenerator = preload("./tree_generator.gd")
const HeightmapCurve = preload("./heightmap_curve.tres")

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE

var _instancer = preload("res://game/generator/image_mapper.gd").new()
var _heightmap_min_y := int(HeightmapCurve.min_value)
var _heightmap_max_y := int(HeightmapCurve.max_value)
var _heightmap_range := 0
var _heightmap_noise := FastNoiseLite.new()


func _init():
	_heightmap_noise.seed = Time.get_unix_time_from_system()
	_heightmap_noise.frequency = 1.0/512.0
	_heightmap_noise.fractal_octaves = 6
	HeightmapCurve.bake()


func _get_used_channels_mask() -> int:
	return 1 << _CHANNEL


func _generate_block(buffer: VoxelBuffer, origin_in_voxels: Vector3i, _lod: int):
	# Assuming input is cubic in our use case (it doesn't have to be!)
	var block_size := int(buffer.get_size().x)
	var ox := int(origin_in_voxels.x)
	var oy := int(origin_in_voxels.y)
	var oz := int(origin_in_voxels.z)
	# TODO This hardcodes a cubic block size of 16, find a non-ugly way...
	# Dividing is a false friend because of negative values
	var chunk_pos := Vector3(
		ox >> 4,
		oy >> 4,
		oz >> 4)

	_heightmap_range = _heightmap_max_y - _heightmap_min_y

	# Ground

	if oy > _heightmap_max_y:
		buffer.fill(0, _CHANNEL)

	elif oy + block_size < _heightmap_min_y:
		buffer.fill(0, _CHANNEL)

	else:
		var rng := RandomNumberGenerator.new()
		rng.seed = _get_chunk_seed_2d(chunk_pos)
		var gx : int
		var gz := int(oz)
		for z in block_size:
			gx = int(ox)
			for x in block_size:
				var height := _get_height_at(gx, gz)
				var relative_height := height - oy

				var pos = Vector3(x, 0, z)
				if relative_height > block_size:
					buffer.fill_area(G.blocks.STONE,
						pos, Vector3(x + 1, block_size, z + 1), _CHANNEL)
				elif relative_height > 0:
					buffer.fill_area(G.blocks.STONE,
						pos, Vector3(x + 1, relative_height, z + 1), _CHANNEL)
					if height >= 0:
						buffer.set_voxel(G.blocks.SOIL, x, relative_height - 1, z, _CHANNEL)
				if height < 16 and oy < 16:
					buffer.fill_area(G.blocks.SAND,
						Vector3(x, max(0, relative_height), z), 
						Vector3(x + 1, block_size, z + 1), _CHANNEL)
				pos.y = oy
				gx += 1
			gz += 1
		if ox % 16 == 0 and oy % 16 == 0 and oz % 16 == 0:
			_instancer.load_chunk(buffer, origin_in_voxels)
	buffer.compress_uniform_channels()


static func _get_chunk_seed_2d(cpos: Vector3) -> int:
	return int(cpos.x) ^ (31 * int(cpos.z))


func _get_height_at(x: int, z: int) -> int:
	var t = 0.5 + 0.5 * _heightmap_noise.get_noise_2d(x, z)
	return int(HeightmapCurve.sample_baked(t))
