const Buff = preload("res://game/unit/buff.gd")

signal changed
signal updated

var _unit
var states = {}


func set_unit(phost):
	_unit = phost


func serialize():
	var r = []
	for i in states.keys():
		var state = states[i]
		r.append([state.name, state.duration])
	return r


func unserialize(p):
	for i in p:
		add(i[0], i[1])


func add(buffname, duration):
	duration = int(duration)
	if states.is_empty():
		G.turn.add(on_turn)
	if buffname in states:
		states[buffname].on_stack(duration)
	else:
		states[buffname] = Buff.make_buff(_unit, buffname, duration)
	emit_signal("changed")


func has(p):
	return p in states


func set_duration(p, dur):
	var state = states.get(p)
	if state != null:
		state.duration = dur


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


func clean(all=false):
	var keys = states.keys()
	for i in keys:
		var state = states[i]
		if all or state.duration != -1:
			state.duration = 0
			if !state.on_turn():
				states.erase(i)
	emit_signal("changed")


func remove():
	G.turn.remove(on_turn)
