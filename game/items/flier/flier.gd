extends "../item.gd"


func use(user: Node3D):
	super(user)
	var forward = -user.camera.basis.z.normalized()
	user.velocity += forward * 60
	user.action.set_next(null, 0.2)
