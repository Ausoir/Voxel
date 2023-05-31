extends "./weapon.gd"

var already_hit = []
var first_hit = false


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
		first_hit = false
		var speed = data.get("speed", 1.0)
		data["swing anim"] = next_anim
		if _user.animator.current_animation == anim_name:
			_user.animator.seek(0, true)
		var weapon_type = data.get("type", "blunt")
		if _user.essence.has(weapon_type):
			if weapon_type == "blunt":
				speed += .2
			else:
				_user.action.cancelable = true
		var anim_dur = animation.get_length() * (1 / speed)
		_user.action.force_set_next("use", anim_dur)
		_user.animator.play(anim_name, .1, speed)


func use2(_user: Node3D):
	_user.take_hit(5)
	_user.buffs.add("regeneration", 5)
	_user.animator.play("swing_down")
	G.ui.set_message("You have not enough shit stuff!")
	_user.action.set_next("idle", .2)


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
							var damage = data.get("damage", 1)
							var buffs = data.get("inflict", [])
							var weapon_type = data.get("type", "blunt")
							unit.on_damaged(_user.position, damage, buffs)
							G.sfx.play("hit_flesh", _user.position)
							_user.emit_signal("weapon", weapon_type, unit)
					else:
						return _deflect(_user, to)
			else:
				var to = from + toward * attack_range_scaled
				return _deflect(_user, to)
			if !first_hit:
				G.sfx.play("swing", _user.position)
				first_hit = true


func _deflect(_user: Node3D, _at: Vector3):
	G.stock.make_debris(_at, 2)
	G.stock.make_particle(_at, "deflect")
	_user.animator.play("RESET")
	_user.equipment.swinging = false
	G.sfx.play("hit_glance", _user.position)

