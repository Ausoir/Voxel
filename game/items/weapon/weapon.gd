extends "../item.gd"


func apply_damage(_user: Node3D, unit: Node3D):
	var damage = data.get("damage", 1)
	var damage_roll = G.rng.roll(1, damage)
	unit.take_hit(damage_roll)
	unit.on_damaged(_user.position)
	var buffs = data.get("buffs", [])
	for buff in buffs:
		unit.buffs.add(buff[0], buff[1])
	if unit.essence.has("goblin"):
		unit.buffs.add("slow", 3)
	if "warrior" in _user.essence and !buffs.has("regeneration cooldown"):
		buffs.add("regeneration", 2)
		buffs.add("regeneration cooldown", 15)
	_user.emit_signal("weapon", data.get("type", "blunt"))
