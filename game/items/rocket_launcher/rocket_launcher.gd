extends "../item.gd"

const RocketScene = preload("./rocket.tscn")

@onready var _world = get_node("/root/Game")


func use(user: Node3D):
	super(user)
	var rocket = RocketScene.instantiate()
	rocket.position = user.get_item_position()
	_world.add_child(rocket)
	var forward = -user.head.basis.z.normalized()
	rocket.set_direction(forward)
	user.action.set_next(null, 1)
