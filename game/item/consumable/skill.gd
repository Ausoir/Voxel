extends "./consumable.gd"


func use_callback(_user: Node3D):
	var skill = data.get("skill")
	if skill != null:
		var fn = Callable(self, skill)
		if fn.is_valid():
			fn.call(_user)
	super(_user)


func summon(_unit: Node3D):
	G.sfx.play("summon", _unit.position)
	for _i in range(data.get("times", 0)):
		var creature = G.rng.pick(data.get("summon"))
		var at = _unit.position + G.rng.v3_spread(1, 0, 1)
		var new = G.stock.make_unit(at, creature)
		G.stock.attach_ai(new, "ally")
		G.sfx.play("summon", _unit.position)
		G.stock.make_particle(at, "summon")


func teleport(_unit: Node3D):
	if _unit == G.you:
		G.player.load_map(data.get("to", "camp"))
		G.sfx.play_bgm("dark")


func amnesia(_unit: Node3D):
	var eq = _unit.equipment
	for i in range(eq.essence.size()):
		var ess = eq.essence[i]
		if ess != null:
			eq.apply_change(ess.data, -1)
			eq.essence[i] = null
			G.sfx.play("buff_ripple", _unit.position)
			eq.emit_signal("changed")
			return

