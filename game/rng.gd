extends Node

var r : RandomNumberGenerator

func _init():
	r = RandomNumberGenerator.new()


func set_seed(sd):
	r.seed = sd


func percent(p):
	return r.randf() < p


func pick(array):
	if array != null and !array.is_empty():
		return array[r.randi_range(0, len(array)-1)]
	return null


func pick_and_pop(array):
	if array != null and !array.is_empty():
		var idx = r.randi_range(0, len(array)-1)
		return array.pop_at(idx)
	return null


func v3_spread(dx, dy, dz):
	var x = r.randf_range(-dx, dx)
	var y = r.randf_range(-dy, dy)
	var z = r.randf_range(-dz, dz)
	return Vector3(x, y, z)


func roll(times, p):
	var v = 0
	for _i in times:
		v += r.randi_range(1, p)
	return v

