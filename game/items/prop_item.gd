extends "res://game/items/prop.gd"

var base


func remove():
	get_parent().remove_child(self)
	queue_free()


func on_interact(_user: Node3D):
	_user.procedure.pickup(base)
	remove()


func get_base():
	return base


func set_item(script):
	base = script
	$Area/Mesh.set_mesh(script.model)


func on_drop():
	$AnimationPlayer.play("drop")
