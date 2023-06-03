extends "./pilot.gd"


func _do_attack(_delta):
	if _dist <= melee_range:
		var hitvoxel = G.tool.raycast(_from, _to, _dist, 8)
		if hitvoxel == null:
			var atkspd = _unit.data.get("aspeed", 1)
			if _unit.action.set_next("delay", atkspd):
				_unit.animator.play("tackle")
		else:
			_pathing.target = G.you.position.floor() + G.rng.v3_spread(1, 0, 1)
			_pathing.perform(_delta)
	elif _dist <= APPROACH_RANGE:
		var to = G.you.position
		_unit.procedure.walk_toward(to)
	else:
		_pathing.target = G.you.position.floor()
		_pathing.perform(_delta)
