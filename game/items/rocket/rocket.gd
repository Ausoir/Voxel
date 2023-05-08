extends "../item.gd"

const RocketScene = preload("./rocket.tscn")


func use_callback(_user: Node3D):
	var rocket = RocketScene.instantiate()
	rocket.position = _user.get_item_position()
	G.stock.add_child(rocket)
	rocket.set_direction(_user.forward)


func use2(user: Node3D):
	G.stock.make_debris(user.get_item_position(), 4)
