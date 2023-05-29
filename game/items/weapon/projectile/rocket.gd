extends "./projectile.gd"


func _ready():
	super()
	G.sfx.play("shoot_laser", position)


func on_collide(hit):
	if hit.collider.collision_layer & 4 > 0:
		var unit = hit.collider.get_parent()
		var damage_roll = G.rng.roll(1, damage)
		unit.take_hit(damage_roll)
		unit.on_damaged(hit.position)
	else:
		G.stock.make_debris(hit.position, 3)
	var tool = G.tool.get_tool()
	tool.value = 0
	tool.do_sphere(hit.position, 3)
	G.stock.make_particle(hit.position, "explosion")
	G.sfx.play("explode", position)
