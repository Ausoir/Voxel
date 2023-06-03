extends "./consumable.gd"


func use_callback(_user: Node3D):
	var dat = data.get("gold", [0, 0])
	G.vars.gold += G.rng.rir(dat[0], dat[1])

