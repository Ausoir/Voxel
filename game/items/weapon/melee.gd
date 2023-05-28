extends "./weapon.gd"

var already_hit = []


func use(_user: Node3D):
	var anim_name = "swing_down"
	var next_anim = -1
	if "swings" in data:
		next_anim = data.get("swing anim", -1) + 1
		if next_anim > data.swings.size() - 1:
			next_anim = 0
		anim_name = data.swings[next_anim]
	var animation = _user.animator.get_animation(anim_name)
	if animation != null:
		already_hit.clear()
		var speed = data.get("speed", 1.0)
		var anim_dur = animation.get_length() * (1 / speed)
		data["swing anim"] = next_anim
		if _user.animator.current_animation == anim_name:
			_user.animator.seek(0, true)
		_user.animator.play(anim_name, .1, speed)
		_user.action.force_set_next("use", anim_dur)


func use2(_user: Node3D):
	_user.take_hit(5)
	_user.buffs.add("regeneration", 5)
	_user.animator.play("swing_down")


func on_held_tick(_user: Node3D):
	if _user.equipment.swinging > 0:
		var from = _user.get_item_position()
		var toward = -_user.held_item_model.get_global_transform().basis.z
		var aabb = _user.held_item_model.mesh.get_aabb()
		var attack_range = -aabb.position.z
		var attack_range_scaled = attack_range * .5 #Item scale 50%
		if _user.equipment.swinging > 1:
			var hitvoxel = G.tool.raycast(from, toward, attack_range_scaled, 8)
			if hitvoxel == null:
				var to = from + toward * attack_range
				var prop = G.tool.collide_prop_by_line(from, to, 4)
				if !prop.is_empty():
					var unit = prop.collider.get_parent()
					if unit.get("faction") != null and unit.faction != _user.faction:
						if !(unit in already_hit):
							already_hit.append(unit)
							apply_damage(unit, _user.position)
					else:
						_deflect(_user, to)
			else:
				var to = from + toward * attack_range_scaled
				_deflect(_user, to)


func _deflect(_user: Node3D, _at: Vector3):
	G.stock.make_debris(_at, 2)
	G.stock.make_particle(_at, "deflect")
	_user.animator.play("RESET")
	_user.equipment.swinging = false

