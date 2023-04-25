extends "res://game/items/prop.gd"

const SELECT_MATERIAL = preload("res://game/items/item_select.tres")

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
	$Mesh.set_mesh(script.model)


func _on_area_mouse_entered():
	$Mesh.set_surface_override_material(0, SELECT_MATERIAL)


func _on_area_mouse_exited():
	$Mesh.set_surface_override_material(0, null)
