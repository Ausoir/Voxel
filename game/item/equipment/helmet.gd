extends "../item.gd"


func on_wear(_user):
	_user.equipment.add_inventory(data.get("space", 0))
	_user.set_head_mesh(model2)


func on_unwear(_user):
	_user.equipment.add_inventory(-data.get("space", 0))
	_user.set_head_mesh(_user.headmesh)

