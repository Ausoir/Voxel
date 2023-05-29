extends "res://game/items/prop.gd"

var _activated = true
var voxel_id
var voxel_pos
var callback = Callable(self, "on_activate")


func _ready():
	save_name = "game/blocks/doors/prop_shutter"


func on_interact(_user: Node3D):
	if !_activated:
		_user.action.set_next("use", 1, callback.bind(_user))
		_user.action.show_progress = true
		_user.action.cancelable = true
		_user.action.turnable = false


func on_activate(_user: Node3D):
	_activated = true
	_user.action.set_next("idle", 0)
	$Animator.play("close")
	G.sfx.play("door_metal", position)


func _on_animator_animation_finished(anim_name):
	_activated = false
	if anim_name == "close":
		G.tool.set_voxel(voxel_pos, voxel_id)
		G.tool.set_voxel(voxel_pos + Vector3.UP, voxel_id)
		queue_free()
