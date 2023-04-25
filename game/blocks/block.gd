extends Node

const NORMAL = 0
const CUSTOM = 1
const ROT2 = 2
const ROT4 = 3
const AXIAL = 4

var id := 0
var sid := ""
var tags := []
var placement := NORMAL
var voxels := []
var custom = false


func on_place(_pos: Vector3):
	pass


func remove(_pos: Vector3):
	pass


func on_interact(_pos: Vector3, _user: Node3D):
	pass
