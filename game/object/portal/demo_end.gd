extends "res://game/object/prop.gd"


func on_interact(_user: Node3D):
	_user.action.set_next("enter", 3, on_activate.bind(_user))
	_user.action.show_progress = true
	_user.action.cancelable = true


func on_activate(_user: Node3D):
	G.sfx.play("door_open", position)
	G.ui.msg("You can't go down further... The demo ends here!")

