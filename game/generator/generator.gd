extends VoxelGeneratorScript

const _CHANNEL = VoxelBuffer.CHANNEL_TYPE

var _mutex = Mutex.new()


func _generate_block(buffer: VoxelBuffer, origin: Vector3i, _lod: int):
	if origin.y == 0:
		_mutex.lock()
		G.map_loader.loads.append(origin)
		_mutex.unlock()
	else:
		buffer.fill(0, _CHANNEL)
	buffer.compress_uniform_channels()

