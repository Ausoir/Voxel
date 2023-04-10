extends Node

signal changed
signal selected

var equipment = {}
var max_inventory_size = 2
var _inventory = []
var _held_index = -1


func _ready():
	update_inventory()


func update_inventory():
	_inventory.resize(max_inventory_size)
	emit_signal("changed")


func add_slot(slot):
	if !(slot in equipment):
		equipment[slot] = null
		emit_signal("changed")


func get_inventory_size():
	return _inventory.size()


func get_held_index():
	return _held_index


func set_held_index(i):
	_adjust_held_index()
	_held_index = i + equipment.size()
	emit_signal("selected")


func set_item_by_index(i, item):
	var eq_size = equipment.size()
	if i < eq_size:
		var key = equipment.keys()[i]
		equipment[key] = item
	else:
		_inventory[i - eq_size] = item
	emit_signal("selected")


func get_held_item():
	return get_item_by_index(_held_index)


func get_item_by_index(i):
	var eq_size = equipment.size()
	if i < eq_size:
		var key = equipment.keys()[i]
		return equipment[key]
	elif i < _inventory.size() + eq_size:
		return _inventory[i - eq_size]


func increment_held_index(i):
	_held_index += i
	_adjust_held_index()
	emit_signal("selected")


func _adjust_held_index():
	var eq_size = equipment.size()
	_held_index = clamp(_held_index, eq_size, eq_size + _inventory.size())


func pickup(item):
	for i in range(_inventory.size()):
		if _inventory[i] == null:
			_inventory[i] = item
			emit_signal("selected")
			return true
