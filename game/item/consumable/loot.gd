extends "./consumable.gd"


func use_callback(_user: Node3D):
	var dict = G.stock.Item_JSON.get_data()
	var itemname = G.rng.pick(dict.keys())
	G.sfx.play("craft", G.you.position)
	G.ui.msg(str("Obtained <", itemname.capitalize(), ">!"))
	var item = G.stock.make_item(itemname)
	if !G.you.equipment.pickup(item):
		item.drop(G.you)
	super(_user)
