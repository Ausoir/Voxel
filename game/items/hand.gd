extends "item.gd"


func use(_user: Node3D):
	_user.motor = Vector3()
	_user.animator.play("RESET")
	if !_pickup(_user):
		_interact(_user)


func _pickup(_user: Node3D):
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
		if !block.on_interact(hit.position, _user):
			if "earth" in _user.essence:
				var plane = _user.forward
				var cardinal = G.tool.cardinalize(_user.forward)
				var dest = _user.position.floor() + G.V2_HALF + cardinal * 2.5
				if G.tool.get_voxel(dest) == 0 and G.tool.get_voxel(dest + Vector3.UP) == 0 and G.tool.get_voxel(dest + Vector3.DOWN) != 0:
					_user.action.set_next("passwall", 3, G.you.camera.set_override.bind(null))
					_user.action.on_tick = G.skills.passwall.bind(_user, dest)
					if _user == G.you:
						G.you.camera.zoom_distance(1)
						G.you.camera.set_override(G.you.camera.position)


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
