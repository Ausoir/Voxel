var host
var states = {}
var in_turn = false

class buff:
	var parent
	var skill
	var fx
	var duration
	var dest
	var turns
	var turn = 0

	func _init(pparent,p1,p2,p3):
		parent = pparent
		skill = p1
		duration = p2
		dest = p3
		turns = p1.get("turns", 0)

	func on_turn(host):
		if duration != -1 and duration <= G.vars.time:
			parent.cancel(skill.name)
			return
		turn += 1
		if "onturn" in skill:
			if turn > turns:
				turn = 0
				G.fx.do(skill, host, dest, 1)


func _init(phost):
	host = phost


func add(skill, duration, dest):
	var dur = G.vars.time + duration
	if duration == -1:
		dur = -1
	if skill.name in states:
		if states[skill.name].duration != -1:
			states[skill.name].duration = dur
	else:
		states[skill.name] = buff.new(self, skill, dur, dest)
		G.world.turn.add(self)


func has(p):
	return p in states


func cancel(p):
	var state = states.get(p)
	if state != null:
		states.erase(p)
		if "onend" in state.skill:
			G.fx.do(state.skill, host, state.dest, 2)
		if states.empty():
			G.world.turn.remove(self)


func on_turn():
	var keys = states.keys()
	for i in keys:
		var state = states[i]
		state.on_turn(host)


func end(p):
	if p in states:
		states[p].duration = 0


func remove():
	states.clear()
	G.world.turn.remove(self)


func clear():
	for i in states:
		states[i].duration = 0
		states[i].on_turn(host)
	states.clear()
	G.world.turn.remove(self)
