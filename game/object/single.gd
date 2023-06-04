extends "res://game/object/prop.gd"


func _ready():
	var pos = position.floor()
	G.tool.set_voxel(pos, 3)


func remove():
	var pos = position.floor()
	G.tool.set_voxel(pos, 0)
	super()
