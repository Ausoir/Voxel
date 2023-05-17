extends "res://game/items/prop.gd"

var _activated = true
var voxel_id
var voxel_pos


func _ready():
	save_name = "game/blocks/doors/prop_divider"


func on_interact(_user: Node3D):
	if !_activated:
		_activated = true
		$Animator.play("close")


func _on_animator_animation_finished(anim_name):
	_activated = false
	if anim_name == "close":
		G.tool.set_voxel(voxel_pos, voxel_id)
		queue_free()
