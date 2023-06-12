

func run(arg: String):
	var unit = G.you
	if arg.begins_with("cheat "):
		var cmd = arg.substr(6)
		if cmd.begins_with("tp "):
			G.player.load_map(cmd.substr(3))
		elif cmd.begins_with("buff "):
			unit.buffs.add(cmd.substr(5), -1)
		elif cmd.begins_with("exp "):
			unit.earn_exp(int(cmd.substr(4)))
		elif cmd == "cure all":
			unit.buffs.clean(true)
		elif cmd == "health":
			unit.health += 1
		elif cmd == "mana":
			unit.mana += 1
		elif cmd == "save":
			G.files.save_player_data()
		elif cmd == "noclip":
			if G.you.body.collision_mask != 0:
				G.you.body.collision_mask = 0
				G.you._box_mover.set_collision_mask(G.you.body.get_collision_mask())
			else:
				G.you.body.collision_mask = 4
				G.you._box_mover.set_collision_mask(G.you.body.get_collision_mask())

