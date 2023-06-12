extends VBoxContainer

const BuffSlot = preload("res://game/ui/buffs/buff_slot.tscn")
var _buffs


func set_unit(p):
	_buffs = p.buffs
	_buffs.connect("changed", reload_views)
	_buffs.connect("updated", update_cooldowns)
	reload_views()


func unset_unit(_unit):
	_unit.buffs.disconnect("changed", reload_views)
	_unit.buffs.disconnect("updated", update_cooldowns)


func update_cooldowns():
	for child in get_children():
		child.update_cooldown()


func reload_views():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for key in _buffs._states.keys():
		var buff = _buffs._states[key]
		var slot = BuffSlot.instantiate()
		add_child(slot)
		slot.set_buff(buff)
