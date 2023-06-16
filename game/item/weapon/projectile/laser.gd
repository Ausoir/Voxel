extends "./projectile.gd"

var _bodies = []

func _ready():
	super()
	$Area3D/CollisionShape3D.shape.radius = radius


func on_effect(_pos):
	G.stock.make_debris(_pos, 7)
	G.stock.make_particle(_pos, "explosion")
	G.sfx.play("explode_short", _pos)
	for hit in _bodies:
		var unit = hit.get_parent()
		unit.set_last_hitter(shooter)
		unit.on_damaged(position, damage, inflict)
		if on_attack != null:
			on_attack.call(unit, shooter, damage)


func _on_area_3d_body_entered(body):
	if body != G.terrain:
		_bodies.append(body)


func _on_area_3d_body_exited(body):
	_bodies.erase(body)
