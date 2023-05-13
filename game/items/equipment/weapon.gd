extends "../item.gd"

const RocketScene = preload("../rocket/rocket.tscn")


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
		var speed = data.get("speed", 1.0)
		var anim_dur = animation.get_length() * (1 / speed)
		data["swing anim"] = next_anim
		if _user.animator.current_animation == anim_name:
			_user.animator.seek(0)
		_user.animator.play(anim_name, .1, speed)
		_user.action.force_set_next("use", anim_dur - .2, callback.bind(_user))


func use2(_user: Node3D):
	_user.animator.play("swing_down")
	_user.on_damaged(_user.position)
	_user.buffs.add("slow", 3)


func use_callback(_user: Node3D):
	_user.animator.play("RESET")


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
						unit.on_damaged(_user.position)
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

