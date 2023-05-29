const Buff = preload("res://game/units/buff.gd")

signal changed
signal updated

var _unit
var states = {}
var _callable = Callable(self, "on_turn")


func set_unit(phost):
	_unit = phost


func add(buffname, duration):
	if states.is_empty():
		G.turn.add(_callable)
	if buffname in states:
		states[buffname].on_stack(duration)
	else:
		states[buffname] = Buff.make_buff(_unit, buffname, duration)
	emit_signal("changed")


func has(p):
	return p in states


func on_turn():
	var dirty = false
	var keys = states.keys()
	for i in keys:
		var state = states[i]
		if !state.on_turn():
			states.erase(i)
			dirty = true
	if dirty:
		emit_signal("changed")
	else:
		emit_signal("updated")
	return !states.is_empty()


func remove():
	G.turn.remove(_callable)
