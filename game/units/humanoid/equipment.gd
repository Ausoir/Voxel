extends Node

signal changed
signal selected

var _unit
var _inventory = []
var _held_index = -1
var equipment = {}
var max_inventory_size = 2
var swinging = false


func _ready():
	update_inventory()


func set_unit(unit):
	_unit = unit


func update_inventory():
	_inventory.resize(max_inventory_size)
	emit_signal("changed")


func add_slot(slot):
	if !(slot in equipment):
		equipment[slot] = null
		emit_signal("changed")


func add_inventory(times):
	max_inventory_size += times
	update_inventory()
	emit_signal("changed")


func get_inventory_size():
	return _inventory.size()


func get_held_index():
	return _held_index


func set_held_index(i):
	_held_index = i + equipment.size()
	_adjust_held_index()
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
	_held_index = clamp(_held_index, eq_size, eq_size + _inventory.size() - 1)


func pickup(item):
	for i in range(_inventory.size()):
		if _inventory[i] == null:
			_inventory[i] = item
			emit_signal("selected")
			return true


func wear(item):
	if item.part != null:
		if item.part in equipment:
			equipment[item.part] = item
			item.on_wear(_unit)


func unwear(item):
	for key in equipment.keys():
		var equipped = equipment[key]
		if equipped == item:
			item.on_unwear(_unit)
			equipment[key] = null
			return item


func use_held(right):
	var inv_item = get_held_item()
	if inv_item != null:
		if right:
			inv_item.use2(_unit)
		else:
			inv_item.use(_unit)


func set_swinging(p):
	swinging = p
