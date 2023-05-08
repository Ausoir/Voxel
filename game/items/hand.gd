extends "item.gd"


func use(_user: Node3D):
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
		block.on_interact(hit.position, _user)


func get_interact_object(_user: Node3D):
	var origin = _user.camera.get_global_transform().origin
	var space_state = _user.get_viewport().get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.collision_mask = 4
	params.set_from(origin)
	params.set_to(origin + _user.forward * 1)
	params.set_collide_with_bodies(false)
	params.set_collide_with_areas(true)
	var hits = space_state.intersect_ray(params)
	return hits


func on_held_tick(_user: Node3D):
	var hit_meta = get_pointed_block(_user, 9)
	if hit_meta != null:
		var block = G.tool.get_block(hit_meta.position)
		if block.on_hover(hit_meta.position):
			return
	G.ui.set_label("")
