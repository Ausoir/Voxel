extends "./pilot.gd"


func _ready():
	super()
	_unit.attack.connect(on_attack)


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


func on_attack():
	var damage = _unit.data.get("damage", 1)
	var buffs = _unit.data.get("inflict", [])
	G.you.on_damaged(_unit.position, damage, buffs)
	_unit.emit_signal("weapon", "unarmed", G.you)
	G.sfx.play("hit_flesh", _unit.position)
