var unit
var cmd
var param


func match_cmd(p):
	cmd = p
	if para("tp"):
		G.player.load_map(param)
	elif para("buff"):
		unit.buffs.add(param, -1)
	elif para("exp"):
		unit.earn_exp(int(param))
	elif para("health"):
		unit.health = int(param)
	elif para("mana"):
		unit.mana = int(param)
	elif para("inflict"):
		unit.data["inflict"] = unit.data.get("inflict", []) + [[cmd.substr(8), 3]]
	elif para("essence"):
		if param in unit.essence:
			unit.essence.erase(param)
		else:
			unit.essence.append(param)
	elif para("cure all"):
		unit.buffs.clean(true)
	elif para("give"):
		unit.equipment.pickup(G.stock.make_item(param))
	elif para("gold"):
		G.vars.gold = int(param)
	elif para("data"):
		var params = param.split(" ")
		unit.data[params[0]] = params[1]
	elif para("save"):
		G.files.save_player_data()
	elif para("godmode"):
		match_cmd("buff invisibility")
		match_cmd("buff vision")
		match_cmd("buff nighteye")
		match_cmd("buff flight")
		match_cmd("noclip")
	elif para("die"):
		unit.die()
	elif para("noclip"):
		if G.you.body.collision_mask != 0:
			G.you.body.collision_mask = 0
			G.you._box_mover.set_collision_mask(G.you.body.get_collision_mask())
		else:
			G.you.body.collision_mask = 4
			G.you._box_mover.set_collision_mask(G.you.body.get_collision_mask())




func para(p):
	if cmd.begins_with(p):
		param = cmd.substr(p.length() + 1)
		return true
	return false

func run(arg: String):
	unit = G.you
	if arg.begins_with("cheat "):
		match_cmd(arg.substr(6))

