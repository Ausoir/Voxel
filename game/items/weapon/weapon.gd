extends "../item.gd"


func apply_damage(unit: Node3D, from: Vector3):
	var damage = data.get("damage", 1)
	var damage_roll = G.rng.roll(1, damage)
	unit.take_hit(damage_roll)
	unit.on_damaged(from)
	var buffs = data.get("buffs", [])
	for buff in buffs:
		unit.buffs.add(buff[0], buff[1])
	if unit.essence.has("goblin"):
		unit.buffs.add("slow", 3)
	if "warrior" in G.you.essence and !buffs.has("regeneration cooldown"):
		buffs.add("regeneration", 2)
		buffs.add("regeneration cooldown", 15)
