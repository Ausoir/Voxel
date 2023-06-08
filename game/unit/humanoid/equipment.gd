extends Node

signal changed
signal selected

var _unit
var equipment = {}
var essence = []
var _inventory = []
var max_essence_size := 1
var max_inventory_size := 2
var _held_index = -1
var swinging: int = 0


func _ready():
	update_inventory()


func set_unit(unit):
	_unit = unit
	max_essence_size = unit.data.get("level", 1)
	update_essence()


func clear(clear_eq=true, clear_ess=true):
	for i in range(_inventory.size()):
		if _inventory[i] != null:
			_inventory[i].queue_free()
			_inventory[i] = null
	_unit.equipment.set_held_index(0)
	if clear_eq:
		var slots = equipment.keys()
		for i in slots:
			if equipment[i] != null:
				apply_change(equipment[i].data, -1)
				equipment[i] = null
	if clear_ess:
		for i in essence:
			if i != null:
				apply_change(i.data, -1)
				essence.erase(i)


func update_essence():
	essence.resize(max_essence_size)
	emit_signal("changed")


func update_inventory():
	_inventory.resize(max_inventory_size)
	var min_index = equipment.size()
	var max_index = min_index + max_inventory_size
	_held_index = clamp(_held_index, min_index, max_index)
	emit_signal("changed")


func add_inventory(times):
	max_inventory_size += times
	if times < 0:
		for i in range(max_inventory_size, _inventory.size()):
			if _inventory[i] != null:
				_inventory[i].drop(_unit)
				_inventory[i] = null
	update_inventory()
	emit_signal("changed")


func add_essence(times):
	max_essence_size += times
	if times < 0:
		for i in range(max_essence_size, essence.size()):
			if essence[i] != null:
				apply_change(essence[i].data, -1)
				essence[i].drop(_unit)
				essence[i] = null
	update_essence()
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
	G.sfx.play("wear", _unit.position)
	var eq_size = equipment.size()
	if i < eq_size:
		var key = equipment.keys()[i]
		unwear(key)
		return wear(item)
	else:
		var ieq_size = eq_size + _inventory.size()
		if i < ieq_size:
			_inventory[i - eq_size] = item
			emit_signal("selected")
		else:
			return absorb(item)


func find_item_by_data(p, val):
	for i in _inventory:
		if i != null and i.data.get(p) == val:
			return i


func get_index_type(i):
	var eq_size = equipment.size()
	if i < eq_size:
		return 0
	else:
		var ieq_size = _inventory.size() + eq_size
		if i < ieq_size:
			return 1
		elif i < ieq_size + essence.size():
			return 2


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


func free_item(p):
	var idx = equipment.size()
	for i in _inventory:
		if i == p:
			set_item_by_index(idx, null)
		idx += 1


func increment_held_index(i):
	_held_index += i
	_adjust_held_index()
	emit_signal("selected")


func _adjust_held_index():
	G.sfx.play("equip_cloth", _unit.position)
	var eq_size = equipment.size()
	_held_index = clamp(_held_index, eq_size, eq_size + _inventory.size() - 1)


func absorb(ess):
	if ess.part != null and ess.part == "essence":
		for i in range(essence.size()):
			if essence[i] == null:
				var reqs = ess.data.get("req")
				if _unit != G.you or reqs == null or G.you.proficiency.check_req(reqs[0], reqs[1]):
					essence[i] = ess
					apply_change(ess.data)
					G.sfx.play("rip", _unit.position)
					emit_signal("changed")
					return 0
				return 1
	return -1


func apply_change(data, mult=1, skip=false):
	if !skip:
		add_inventory(data.get("space", 0) * mult)
		add_essence(data.get("soul", 0) * mult)
	if "essence" in data:
		if mult == -1:
			_unit.essence.erase(data.essence)
		else:
			_unit.essence.append(data.essence)
	_unit.data.health += data.get("health", 0) * mult
	_unit.data.mana += data.get("mana", 0) * mult
	_unit.defense += data.get("defense", 0) * mult
	_unit.procedure.speed -= data.get("weight", 0)*.1 * mult


func pickup(item):
	for i in range(_inventory.size()):
		if _inventory[i] == null:
			_inventory[i] = item
			emit_signal("selected")
			return true
	return false


func wear(item):
	if item != null and item.part != null:
		if item.part in equipment:
			if equipment[item.part] == null:
				var reqs = item.data.get("req")
				if _unit != G.you or reqs == null or G.player.proficiency.check_req(reqs[0], reqs[1]):
					equipment[item.part] = item
					item.on_wear(_unit)
					apply_change(item.data)
					emit_signal("changed")
					return true
	return false


func unwear(key):
	var equipped = equipment[key]
	if equipped != null:
		apply_change(equipped.data, -1)
		equipped.on_unwear(_unit)
		equipment[key] = null
		emit_signal("changed")
		return equipped


func check_essence(p):
	for i in equipment.keys():
		var eq = equipment[i]
		if eq != null and eq.data.get("essence", "") == p:
			return true
	return false


func set_swinging(p):
	swinging = p


func remove():
	pass


func serialize():
	var equips = []
	var esss = []
	var items = []
	var slots = equipment.keys()
	for i in slots:
		if equipment[i] != null:
			apply_change(equipment[i].data, -1, true)
			equips.append(equipment[i].sid)
	for i in _inventory:
		if i != null:
			items.append(i.sid)
	for i in essence:
		if i != null:
			apply_change(i.data, -1, true)
			esss.append(i.sid)
	var r = {
		"slots": equipment.keys(),
		"equipments": equips,
		"items": items,
		"souls": esss,
	}
	return r
