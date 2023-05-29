extends Node

var rng : RandomNumberGenerator

func _init():
	rng = RandomNumberGenerator.new()


func set_seed(sd):
	rng.seed = sd


func rf():
	return rng.randf()


func percent(p):
	return rng.randf() < p


func pick(array):
	if array != null and !array.is_empty():
		return array[rng.randi_range(0, len(array)-1)]
	return null


func pick_and_pop(array):
	if array != null and !array.is_empty():
		var idx = rng.randi_range(0, len(array)-1)
		return array.pop_at(idx)
	return null


func v3_spread(dx, dy, dz):
	var x = rng.randf_range(-dx, dx)
	var y = rng.randf_range(-dy, dy)
	var z = rng.randf_range(-dz, dz)
	return Vector3(x, y, z)


func roll(times, p):
	var v = 0
	for _i in times:
		v += rng.randi_range(1, p)
	return v


func get_combo(dat, val: float):
	for i in dat:
		if val < i[0]:
			return i[1]
