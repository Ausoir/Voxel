extends "res://game/object/single.gd"

var shooter
var damage


func _on_timer_timeout():
	var pos = position + Vector3(0, .5, 0)
	var hits = G.tool.collide_prop_by_shape(pos, 3, 4)
	for hit in hits:
		var unit = hit.collider.get_parent()
		if unit.get("buffs") != null:
			if shooter != unit:
				unit.set_last_hitter(shooter)
			unit.on_damaged(pos, 9, [["down", 5]])
	G.stock.make_debris(pos, 7)
	G.stock.make_particle(pos, "explosion")
	G.sfx.play("explode", pos)
	G.tool.set_voxel(pos, 0)
	for i in G.CARDINALS:
		G.tool.set_voxel(pos+i, 0)
		G.tool.set_voxel(pos+i+Vector3.UP, 0)
	remove()
