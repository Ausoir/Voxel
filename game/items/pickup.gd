extends "item.gd"


func use(_user: Node3D):
	return get_pointed_item(_user)
