

func passwall(_user, to):
	_user.position = _user.position.lerp(to, 0.01)
