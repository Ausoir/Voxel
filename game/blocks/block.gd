extends Node

const NORMAL = 0
const CUSTOM = 1
const ROT2 = 2
const ROT4 = 3
const AXIAL = 4

var id := 0
var sid := ""
var icon
var tags := []
var data
var placement := NORMAL
var voxels := []
var custom = false
var tickable = false


func on_place(_pos: Vector3):
	pass


func on_remove(_pos: Vector3):
	pass


func on_interact(_pos: Vector3, _user: Node3D):
	return false


func on_hover(_pos: Vector3):
	pass


func on_turn(_pos: Vector3):
	pass


func on_step(_pos: Vector3):
	var mat = data.get("material", "dirt")
	if mat != "none":
		G.sfx.play("step_"+mat, _pos)
