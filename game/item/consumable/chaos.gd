extends "./consumable.gd"


func use_callback(_user: Node3D):
	var ess
	while ess == null or ess in data.exclude:
		ess = G.rng.pick(G.stock.essence_list)
	G.sfx.play("craft", G.you.position)
	G.ui.msg(str("Obtained <", ess.capitalize(), ">!"))
	var item = G.stock.make_item(ess + ":-1")
	if !G.you.equipment.pickup(item):
		item.drop(G.you)
	super(_user)
