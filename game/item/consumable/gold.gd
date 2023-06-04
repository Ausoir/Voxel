extends "./consumable.gd"


func use_callback(_user: Node3D):
	var dat = data.get("gold", [0, 0])
	var income = G.rng.rir(dat[0], dat[1])
	G.vars.gold += income
	G.sfx.play("buy", G.you.position)
	G.ui.set_message(str("Obtained ", income, " gold."))
	super(_user)
