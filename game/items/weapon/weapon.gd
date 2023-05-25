extends "../item.gd"


func apply_damage(unit: Node3D, from: Vector3):
	var damage = data.get("damage", 1)
	var damage_roll = G.rng.roll(1, damage)
	unit.take_hit(damage_roll)
	unit.on_damaged(from)

