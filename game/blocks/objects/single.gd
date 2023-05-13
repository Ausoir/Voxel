extends Node3D


func _ready():
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)


func remove():
	var pos = position.floor()
	G.tool.set_voxel(pos, 0)
	queue_free()
