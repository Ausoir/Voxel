const Buff = preload("res://game/unit/buff.gd")

signal changed
signal updated

var _unit
var _states = {}


func set_unit(phost):
	_unit = phost


func serialize():
	var r = []
	for i in _states.keys():
		var state = _states[i]
		r.append([state.name, state.duration])
	return r


func unserialize(p):
	add_all(p)


func add_all(list):
	for buff in list:
		add(buff[0], buff[1])


func add(buffname, duration):
	var r
	duration = int(duration)
	var empty = _states.is_empty()
	if buffname in _states:
		_states[buffname].on_stack(duration)
	else:
		var buff_class = Buff.get_buff(buffname)
		var buff = buff_class.new(_unit, duration)
		if buff.req_met():
			buff.name = buffname
			var path = str("ui/st_", buffname.replace(" ", "_"))
			buff.sprite = G.stock.get_image(path)
			_states[buffname] = buff
			buff.on_start()
			r = buff
	if empty and !_states.is_empty():
		G.turn.add(on_turn)
	emit_signal("changed")
	return r


func has(p):
	return p in _states


func get_duration(p):
	var state = _states.get(p)
	if state != null:
		return state.duration
	return -2


func set_duration(p, dur):
	var state = _states.get(p)
	if state != null:
		state.duration = dur


func on_turn():
	var dirty = false
	var keys = _states.keys()
	for i in keys:
		var state = _states.get(i)
		if state != null: #index changed by a buff.on_turn during loop
			if !state.on_turn():
				_states.erase(i)
				dirty = true
	if dirty:
		emit_signal("changed")
	else:
		emit_signal("updated")
	return !_states.is_empty()


func clean(all=false):
	var keys = _states.keys()
	for i in keys:
		var state = _states.get(i)
		if state != null: #index changed by a buff.on_turn during loop
			if all or state.duration != -1:
				state.duration = 0
				if !state.on_turn():
					_states.erase(i)
	emit_signal("changed")


func pre_save():
	var keys = _states.keys()
	for i in keys:
		var state = _states[i]
		if !state.pre_save():
			state.duration = 0
			if !state.on_turn():
				_states.erase(i)


func remove():
	G.turn.remove(on_turn)
