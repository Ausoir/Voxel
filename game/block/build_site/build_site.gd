extends "../block.gd"

const Site = preload("./prop_build_site.tscn")

var t_metadata


func on_place(_pos: Vector3):
	if t_metadata != null:
		G.tool.get_tool().set_voxel_metadata(_pos, t_metadata)
		var block = G.blocks.get_block_by_name(t_metadata)
		G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
		G.tool.set_voxel(_pos, block.data.get("effort", 0))
		G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)


func on_remove(_pos: Vector3):
	G.tool.get_tool().set_voxel_metadata(_pos, null)
	G.stock.make_debris(_pos, 4)
	G.stock.make_particle(_pos, "explosion")


func on_hover(_pos: Vector3):
	var meta = G.tool.get_tool().get_voxel_metadata(_pos)
	if meta == null:
		var below = _pos + Vector3(0, -1, 0)
		meta = G.tool.get_tool().get_voxel_metadata(below)
	if meta != null:
		G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
		var effort = G.tool.get_voxel(_pos)
		G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
		var text = str("Building ", meta.capitalize(), " ", effort, "s")
		G.ui.set_label(text)
		return true


func on_tick(_pos: Vector3):
	G.tool.set_channel(VoxelBuffer.CHANNEL_DATA5)
	var progress = G.tool.get_voxel(_pos)
	if progress <= 0:
		G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
		var above = _pos + Vector3(0, 1, 0)
		var above_meta = G.tool.get_tool().get_voxel_metadata(above)
		if above_meta == null:
			G.tool.set_voxel(above, 0)
		var meta = G.tool.get_tool().get_voxel_metadata(_pos)
		G.tool.set_block_by_name(_pos, meta, Vector3.UP)
		return false
	else:
		G.tool.set_voxel(_pos, progress - 1)
	G.tool.set_channel(VoxelBuffer.CHANNEL_TYPE)
