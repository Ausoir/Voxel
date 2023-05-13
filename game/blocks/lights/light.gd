extends "../block.gd"

const Light = preload("./light.tscn")


func on_place(_pos: Vector3):
	var light = Light.instantiate()
	G.stock.add_child(light)
	light.set_strength(data.get("light", 5))
	light.position = _pos + Vector3(.5, .25, .5)


func on_remove(_pos: Vector3):
	var hit = G.tool.collide_prop_by_shape(_pos + Vector3(.5, .25, .5), .1, 8)
	if !hit.is_empty():
		var prop = hit[0].collider.get_parent()
		prop.queue_free()
