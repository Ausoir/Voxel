extends Node

signal changed
signal selected

var _unit
var equipment = {}
var essence = []
var _inventory = []
var max_inventory_size = 2
var _held_index = -1
var swinging: int = 0


func _ready():
	update_inventory()
	update_essence(2)


func set_unit(unit):
	_unit = unit


func update_essence(p):
	essence.resize(p)
	emit_signal("changed")


func update_inventory():
	_inventory.resize(max_inventory_size)
	emit_signal("changed")


func add_inventory(times):
	max_inventory_size += times
	update_inventory()
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
	_held_index = i + equipment.size()
	_adjust_held_index()
	emit_signal("selected")


func set_item_by_index(i, item):
	var eq_size = equipment.size()
	if i < eq_size:
		var key = equipment.keys()[i]
		unwear(key)
		wear(item)
	else:
		var ieq_size = eq_size + _inventory.size()
		if i < ieq_size:
			_inventory[i - eq_size] = item
		elif item.part != null and item.part == "essence":
			absorb(item)
			return
	emit_signal("selected")


func get_held_item():
	return get_item_by_index(_held_index)


func get_item_by_index(i):
	var eq_size = equipment.size()
	if i < eq_size:
		var key = equipment.keys()[i]
		return equipment[key]
	else:
		var ieq_size = _inventory.size() + eq_size
		if i < ieq_size:
			return _inventory[i - eq_size]
		elif i < ieq_size + essence.size():
			return essence[i - ieq_size]


func increment_held_index(i):
	_held_index += i
	_adjust_held_index()
	emit_signal("selected")


func _adjust_held_index():
	var eq_size = equipment.size()
	_held_index = clamp(_held_index, eq_size, eq_size + _inventory.size() - 1)


func absorb(ess):
	for i in range(essence.size()):
		if essence[i] == null:
			essence[i] = ess
			_unit.essence.append(ess.data.essence)
			_unit.procedure.speed += ess.data.get("speed", 0)
			_unit.health += ess.data.get("health", 0)
			emit_signal("changed")
			return true


func pickup(item):
	for i in range(_inventory.size()):
		if _inventory[i] == null:
			_inventory[i] = item
			emit_signal("selected")
			return true


func wear(item):
	if item != null and item.part != null:
		if item.part in equipment:
			if equipment[item.part] == null:
				equipment[item.part] = item
				item.on_wear(_unit)
				emit_signal("changed")
				return true
	return false


func unwear(key):
	var equipped = equipment[key]
	if equipped != null:
		equipped.on_unwear(_unit)
		equipment[key] = null
		emit_signal("changed")
		return equipped


func use_held(right):
	var inv_item = get_held_item()
	if inv_item != null:
		if right:
			inv_item.use2(_unit)
		else:
			inv_item.use(_unit)


func set_swinging(p):
	swinging = p


func remove():
	pass
