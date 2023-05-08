extends "../item.gd"


func use(user: Node3D):
	user.equipment.wear(self)


func on_wear(_user):
	_user.equipment.add_inventory(data.get("space", 0))
	_user.set_mesh(model)


func on_unwear(_user):
	_user.equipment.add_inventory(-data.get("space", 0))
#	var orig_model = _user.data["model"]
#	_user.set_mesh(orig_model)

