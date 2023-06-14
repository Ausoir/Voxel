extends "res://game/object/prop.gd"

@export var destination : String


func _ready():
	sid = "portal"
	var pos = position.floor()
	var above = position.floor() + Vector3.UP
	var meta = "Use Portal"
	G.tool.get_tool().set_voxel_metadata(pos, meta)
	G.tool.get_tool().set_voxel_metadata(above, meta)
	G.tool.set_voxel(pos, 1)
	G.tool.set_voxel(above, 1)


func remove():
	var pos = position.floor()
	var above = position.floor() + Vector3.UP
	G.tool.set_voxel(pos, 0)
	G.tool.set_voxel(above, 0)
	G.tool.get_tool().set_voxel_metadata(pos, null)
	G.tool.get_tool().set_voxel_metadata(above, null)
	super()


func on_interact(_user: Node3D):
	_user.action.set_next("enter", 3, on_activate.bind(_user))
	_user.action.show_progress = true
	_user.action.cancelable = true


func on_activate(_user: Node3D):
	G.sfx.play("door_open", position)
	if destination == "#down":
		if G.you.buffs.has("hunger"):
			G.ui.msg("Too hungry to go down!")
		else:
			G.player.load_map(G.mapdata.down)
	else:
		G.player.load_map(destination)

