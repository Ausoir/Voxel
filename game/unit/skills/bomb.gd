extends "res://game/object/single.gd"

var shooter
var damage


func _on_timer_timeout():
	var pos = position + Vector3(0, .5, 0)
	var hits = G.tool.collide_prop_by_shape(pos, 3, 4)
	for hit in hits:
		var unit = hit.collider.get_parent()
		if unit.get("buffs") != null:
			unit.last_hitter = shooter
			unit.on_damaged(pos, 9, [["down", 5]])
	G.stock.make_debris(pos, 7)
	G.stock.make_particle(pos, "explosion")
	G.sfx.play("explode", pos)
	remove()
