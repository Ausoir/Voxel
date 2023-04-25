extends Node3D

var save_name


func serialize():
	var r = {
		"name": save_name,
		"position": [global_position.x, global_position.y, global_position.z],
	}
	return r
