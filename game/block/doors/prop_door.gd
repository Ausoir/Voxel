extends "res://game/object/prop.gd"

var _activated = true
var voxel_ids
var voxel_pos
var callback = Callable(self, "on_activate")


func _ready():
	sid = "game/blocks/doors/prop_door"


func on_interact(_user: Node3D):
	_user.action.set_next("use", 1, callback.bind(_user))
	_user.action.show_progress = true
	_user.action.cancelable = true
	_user.action.turnable = false


func on_activate(_user: Node3D):
	if !_activated:
		_user.action.set_next("idle", 0)
		$Animator.play("close2")
		G.sfx.play("door_creak", position)
	else:
		_user.action.set_next("idle", 0)
		$Animator.play("open2")
		G.sfx.play("door_open", position)


func _on_animator_animation_finished(anim_name):
	_activated = !_activated
	if anim_name == "close2":
		queue_free()


func _on_close():
	G.tool.set_voxel(voxel_pos, voxel_ids[0])
	G.tool.set_voxel(voxel_pos + Vector3.UP, voxel_ids[1])
