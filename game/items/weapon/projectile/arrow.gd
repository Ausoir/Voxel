extends "./projectile.gd"


func on_collide(hit):
	if hit.collider.collision_layer & 4 > 0:
		var unit = hit.collider.get_parent()
		var damage_roll = G.rng.roll(1, damage)
		unit.take_hit(damage_roll)
		unit.on_damaged(hit.position)
	else:
		G.stock.make_debris(hit.position, 2)
