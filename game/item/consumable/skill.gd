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
		G.stock.make_particle(at, "summon")
		var new = G.stock.make_any_unit(G.stock, at, creature)
		G.stock.attach_ai(new, "ally")


func teleport(_unit: Node3D):
	G.player.load_map(data.get("to", "camp"))


func amnesia(_unit: Node3D):
	var eq = G.you.equipment
	for i in range(eq.essence.size()):
		var ess = eq.essence[i]
		if ess != null:
			eq.apply_change(ess.data, -1)
			eq.essence[i] = null
			return

