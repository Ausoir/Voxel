extends "../item.gd"


func use(user: Node3D):
	user.equipment.wear(self)


func on_wear(_user):
	_user.set_mesh(model2)


func on_unwear(_user):
	_user.set_mesh(G.stock.Underwear)

