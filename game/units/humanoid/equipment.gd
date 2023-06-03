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


func update_essence():
	essence.resize(max_essence_size)
	emit_signal("changed")


func update_inventory():
	_inventory.resize(max_inventory_size)
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


func free_held():
	set_item_by_index(_held_index, null)


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
				if _unit != G.you or reqs == null or G.player.proficiency.check_req(reqs[0], reqs[1]):
					essence[i] = ess
					_unit.essence.append(ess.data.essence)
					apply_change(ess.data)
					G.sfx.play("rip", _unit.position)
					emit_signal("changed")
					return 0
				return 1
	return -1


func apply_change(data, mult=1):
	add_inventory(data.get("space", 0) * mult)
	add_essence(data.get("soul", 0) * mult)
	_unit.procedure.speed += data.get("speed", 0) * mult
	_unit.health += data.get("health", 0) * mult
	_unit.defense += data.get("defense", 0) * mult


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


func serialize():
	var equips = []
	var esss = []
	var items = []
	var slots = equipment.keys()
	for i in slots:
		if equipment[i] != null:
			equips.append(equipment[i].sid)
	for i in _inventory:
		if i != null:
			items.append(i.sid)
	for i in essence:
		if i != null:
			esss.append(i.sid)
	var r = {
		"slots": equipment.keys(),
		"equipments": equips,
		"items": items,
		"souls": esss,
	}
	return r
