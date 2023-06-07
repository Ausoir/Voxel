extends "../item.gd"


func on_wear(_user):
	_user.set_mesh(model2)


func on_unwear(_user):
	_user.set_mesh(_user.bodymesh)

