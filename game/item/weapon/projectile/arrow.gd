extends "./projectile.gd"


func _ready():
	super()
	G.sfx.play("shoot_bow", position)


func on_collide(hit):
	if hit.collider.collision_layer & 8 > 0:
		var unit = hit.collider.get_parent()
		unit.on_damaged(position, damage, inflict)
		if on_attack != null:
			on_attack.call(unit)
	else:
		G.stock.make_debris(hit.position, 2)
