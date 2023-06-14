extends HBoxContainer

const ITEMSLOT = preload("res://game/ui/inventory/item_slot.tscn")

var _inventory


func set_unit(unit):
	_inventory = unit.equipment
	update_views()


func update_views():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for i in range(_inventory.max_inventory_size):
		var new = ITEMSLOT.instantiate()
		add_child(new)
		new.set_item(_inventory.get_item_by_index(i + _inventory.equipment.size()))
		new.set_selected(i == _inventory.get_held_index())


func update_items():
	for i in range(_inventory.max_inventory_size):
		var child = get_child(i)
		child.set_item(_inventory.get_item_by_index(i + _inventory.equipment.size()))
		child.set_selected(i == _inventory.get_held_index())


func get_selected_item():
	return _inventory.get_held_item()
