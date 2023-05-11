extends VBoxContainer

const BuffSlot = preload("res://game/ui/buffs/buff_slot.tscn")
var _buffs


func set_unit(p):
	_buffs = p.buffs
	_buffs.connect("changed", Callable(self, "reload_views"))
	_buffs.connect("updated", Callable(self, "update_cooldowns"))


func update_cooldowns():
	for child in get_children():
		child.update_cooldown()


func reload_views():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for key in _buffs.states.keys():
		var buff = _buffs.states[key]
		var slot = BuffSlot.instantiate()
		add_child(slot)
		slot.set_buff(buff)
