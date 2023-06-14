extends "res://game/object/prop.gd"

var base


func remove():
	get_parent().remove_child(self)
	queue_free()


func on_interact(_user: Node3D):
	_user.equipment.set_inventory_item(_user.equipment.get_held_index(), base)
	_user.action.set_next("idle", 0.5)
	_user.action.show_progress = true
	remove()


func get_base():
	return base


func set_item(script):
	base = script
	$Area/Mesh.set_mesh(script.model)


func on_drop():
	$AnimationPlayer.play("drop")
