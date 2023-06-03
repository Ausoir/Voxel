extends "item.gd"


func use(_user: Node3D):
	_user.motor = Vector3()
	_user.animator.play("RESET")
	if !_pickup(_user):
		if !_interact(_user):
			if !_user.skills.on_touch():
				return false
	return true


func _pickup(_user: Node3D):
	if _user.get_type() == 1:
		var hits = get_interact_object(_user)
		if !hits.is_empty():
			var _item = hits.collider.get_parent()
			_item.on_interact(_user)
			return true
	return false


func _interact(_user: Node3D):
	var hit = get_pointed_block(_user)
	if hit != null:
		var block = G.tool.get_block(hit.position)
		if block != null:
			if block.on_interact(hit.position, _user):
				return true
	return false


func get_interact_object(_user: Node3D):
	var origin = _user.camera.global_position
	return G.tool.collide_prop_by_line(origin, origin + _user.forward * 2, 1)


func on_held_tick(_user: Node3D):
	var hit_meta = get_pointed_block(_user, 9)
	if hit_meta != null:
		var block = G.tool.get_block(hit_meta.position)
		if block != null and block.on_hover(hit_meta.position):
			return
	G.ui.set_label("")
