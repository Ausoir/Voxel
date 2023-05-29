extends "./projectile.gd"


func on_collide(hit):
	if hit.collider.collision_layer & 4 > 0:
		var unit = hit.collider.get_parent()
		unit.on_damaged(position, damage, [])
		on_attack.call(unit)
	else:
		G.stock.make_debris(hit.position, 3)
	G.stock.make_particle(hit.position, "explosion")
