extends Node3D

var sid


func serialize():
	var r = {
		"name": sid,
		"position": [global_position.x, global_position.y, global_position.z],
	}
	return r
