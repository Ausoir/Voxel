extends "../item.gd"

const RocketScene = preload("./rocket.tscn")


func use(user: Node3D):
	super(user)
	var rocket = RocketScene.instantiate()
	rocket.position = user.get_item_position()
	G.stock.add_child(rocket)
	var forward = -user.head.basis.z.normalized()
	rocket.set_direction(forward)
	user.action.set_next(null, 0.3)


func use2(user: Node3D):
	G.stock.make_debris(user.get_item_position(), 4)
