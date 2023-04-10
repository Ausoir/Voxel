extends "../item.gd"


func use(user: Node3D):
	super(user)
	var forward = -user.head.basis.z.normalized()
	user._velocity += forward * 80
	user.action.set_next(null, 0.2)
