extends "res://game/items/prop.gd"

var _base


func remove():
	queue_free()


func on_interact(_user: Node3D):
	_user.procedure.pickup(_base)
	remove()


func get_base():
	return _base


func set_item(script):
	_base = script
	$Area/Mesh.set_mesh(script.model)


func on_drop():
	$AnimationPlayer.play("drop")
