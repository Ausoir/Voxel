extends "../item.gd"

const RocketScene = preload("../rocket/rocket.tscn")


func use2(user: Node3D):
	G.stock.make_debris(user.get_item_position(), 4)


func on_held_tick(_user: Node3D):
	if _user.equipment.swinging:
		var from = _user.get_item_position()
		var toward = -_user.held_item_model.get_global_transform().basis.z
		var aabb = _user.held_item_model.mesh.get_aabb()
		var attack_range = -aabb.position.z
		var attack_range_scaled = attack_range * .5 #Item scale 50%
		var hitvoxel = G.tool.raycast(from, toward, attack_range_scaled, 8)
		if hitvoxel == null:
			var to = from + toward * attack_range
			var prop = G.tool.collide_prop_by_line(from, to, 4)
			if !prop.is_empty():
				var unit = prop.collider.get_parent()
				if unit != _user:
					unit.remove()
					G.stock.make_debris(prop.position, 4)
					G.stock.make_particle(prop.position, "explosion")
		else:
			var pos = hitvoxel.position
			G.stock.make_debris(pos, 2)
			G.stock.make_particle(pos, "explosion")
			_user.animator.play("RESET")
			_user.equipment.swinging = false
