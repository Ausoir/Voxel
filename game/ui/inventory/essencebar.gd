extends HBoxContainer

const ITEMSLOT = preload("res://game/ui/inventory/item_slot.tscn")
const BACKGROUND = preload("res://assets/ui/eq_soul.png")

var _inventory


func set_unit(unit):
	_inventory = unit.equipment
	update_views()


func update_views():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for ess in _inventory.essence:
		var new = ITEMSLOT.instantiate()
		add_child(new)
		new.set_item(ess, BACKGROUND)
