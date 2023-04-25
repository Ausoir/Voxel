extends Node

var r : RandomNumberGenerator

func _init():
	r = RandomNumberGenerator.new()


func set_seed(sd):
	r.seed = sd


func pick(array):
	if array != null and !array.is_empty():
		return array[r.randi_range(0, len(array)-1)]
	return null
