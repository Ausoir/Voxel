extends HBoxContainer

const ITEMSLOT = preload("res://game/ui/inventory/item_slot.tscn")

var _inventory


func set_unit(unit):
	_inventory = unit.equipment
	_inventory.connect("changed", Callable(self, "update_views"))
	_inventory.connect("selected", Callable(self, "update_items"))
	update_views()


func update_views():
	for child in get_children():
		child.queue_free()
	for i in range(_inventory.equipment.size()):
		var new = ITEMSLOT.instantiate()
		add_child(new)
		var key = _inventory.equipment.keys()[i]
		new.set_item(_inventory.equipment[key])


func update_items():
	for i in range(_inventory.equipment.size()):
		var child = get_child(i)
		var key = _inventory.equipment.keys()[i]
		child.set_item(_inventory.equipment[key])


func equip(item):
	var part = item.data.get("part")
	if part != null:
		_inventory.equipment[part] = item
		update_views()


func get_selected_item():
	return _inventory.get_held_item()
