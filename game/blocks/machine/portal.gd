extends Node3D

@export var destination : String


func _ready():
	var pos = position.floor()
	G.tool.set_voxel(pos, 4)
	var meta = "Use Portal"
	G.tool.get_tool().set_voxel_metadata(pos, meta)


func remove():
	var pos = position.floor()
	G.tool.set_voxel(pos, 0)
	G.tool.get_tool().set_voxel_metadata(pos, null)
	queue_free()


func on_interact(_user: Node3D):
	_user.action.set_next("enter", 1, on_activate.bind(_user))
	_user.action.show_progress = true
	_user.action.cancelable = true


func on_activate(_user: Node3D):
	G.sfx.play("door_open", position)
	G.player.load_map(destination)

