extends "../item.gd"

var already_hit = []
var first_hit = false


func use(_user: Node3D):
	var anim_name = "swing_down"
	var next_anim = -1
	var speed = data.get("speed", 1.0)
	if _user.grounded:
		if "swings" in data:
			next_anim = data.get("swing anim", -1) + 1
			if next_anim > data.swings.size() - 1:
				next_anim = 0
			anim_name = data.swings[next_anim]
		_user.procedure.speedmod = 0.5
	else:
		speed += 1
		_user.procedure.speedmod = 0
	if _user.animator.current_animation == anim_name:
		_user.animator.stop()
	var animation = _user.animator.get_animation(anim_name)
	if animation != null:
		already_hit.clear()
		first_hit = false
		data["swing anim"] = next_anim
		var weapon_type = data.get("type", "blunt")
		if weapon_type == "blade":
			if _user.has_essence("blade"):
				_user.action.cancelable = true
				speed += 0.2
		elif weapon_type == "spear":
			if _user.has_essence("spear"):
				_user.procedure.speedmod = .8
		if _user.has_essence("berserk"):
			speed += 0.4
		if _user.has_essence("knockdown"):
			if knockdown(_user):
				return
		var anim_dur = animation.get_length() * (1 / speed)
		if data.get("swings", []).size() <= 1:
			_user.action.force_set_next("use", anim_dur, _user.animator.stop)
		else:
			_user.action.force_set_next("use", anim_dur)
		_user.animator.play(anim_name, .1, speed)


func on_held_tick(_user: Node3D):
	if _user.equipment.swinging > 0:
		var from = _user.get_item_position()
		var toward = -_user.held_item_model.get_global_transform().basis.z
		var aabb = _user.held_item_model.mesh.get_aabb()
		var attack_range = -aabb.position.z
		var attack_range_scaled = attack_range * _user.held_item_model.scale.z
		if _user.equipment.swinging > 1:
			var hitvoxel = G.tool.raycast(from, toward, attack_range_scaled, 8)
			if hitvoxel == null:
				var to = from + toward * (attack_range - .1)
				var prop = G.tool.collide_prop_by_line(from, to, 4)
				var line_hit = true
				if prop.is_empty():
					line_hit = false
					var exc = [_user.body_rid]
					prop = G.tool.collide_prop_by_shape(to, .1, 4, exc).pop_front()
					if prop == null:
						if !first_hit:
							G.sfx.play("swing", _user.position)
							first_hit = true
						return false
				var unit = prop.collider.get_parent()
				var faction = unit.get("faction")
				if faction != null and faction != _user.faction:
					on_hitting(_user, unit)
				elif line_hit:
					return _deflect(_user, to)
			else:
				var to = from + toward * attack_range_scaled
				return _deflect(_user, to)


func on_hitting(_user, unit):
	if !(unit in already_hit):
		already_hit.append(unit)
		var damage = data.get("damage", 1)
		var inflict = data.get("inflict", []) + _user.data.get("inflict", [])
		var weapon_type = data.get("type", "blunt")
		if weapon_type == "blunt":
			if _user.has_essence("blunt"):
				if !_user.buffs.has("exhaustion"):
					inflict = inflict + [["sleep", 1]]
					_user.buffs.add("exhaustion", max(1, 10 - _user.get_prof("blunt")))
					G.sfx.play("critical", _user.position)
		var damage_roll = G.rng.damage_roll(damage, _user.get_prof(weapon_type))
		if !unit.alert:
			damage_roll += data.get("backstab", 0) + 3
			if weapon_type == "dagger":
				damage_roll += _user.get_prof("dagger") * 3
				if _user.has_essence("dagger"):
					damage_roll *= 2
			_user.emit_signal("critical", unit)
		damage_roll += _user.data.get("damage", 0)
		unit.set_last_hitter(_user)
		unit.on_damaged(_user.position, damage_roll, inflict)
		G.sfx.play("hit_flesh", _user.position)
		_user.emit_signal("weapon", weapon_type, unit, damage_roll)
		if G.rng.percent(data.get("buffc", 0) * 0.09):
			var take = data.get("buff", [])
			_user.buffs.add_all(take)


func _deflect(_user: Node3D, _at: Vector3):
	G.stock.make_debris(_at, 2)
	G.stock.make_particle(_at, "deflect")
	_user.animator.play("RESET")
	_user.equipment.swinging = false
	G.sfx.play("hit_glance", _user.position)
	G.tool.set_sound(_at, 7)


func knockdown(_user: Node3D):
	if !_user.buffs.has("exhaustion"):
		var hits = _user.procedure.collide_front()
		if !hits.is_empty():
			for hit in hits:
				var unit = hit.collider.get_parent()
				unit.set_last_hitter(_user)
				_user.action.force_set_next("flip", 1.2)
				_user.animator.play("flip")
				unit.buffs.add("down", 1)
				unit.velocity += ((unit.position-_user.position).normalized() + Vector3.UP) * 8
				_user.buffs.add("exhaustion", 16)
			return true
	return false
