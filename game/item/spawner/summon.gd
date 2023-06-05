extends "../item.gd"


func use(_user: Node3D):
	var hit = get_pointed_block(_user, 4)
	if hit != null:
		var pos = hit.previous_position
		if G.tool.collide_prop_by_shape(pos, .7, 2).size() == 0:
			G.stock.make_any(pos, "bunny")
		_user.action.set_next("idle", .4)

