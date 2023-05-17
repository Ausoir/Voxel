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
