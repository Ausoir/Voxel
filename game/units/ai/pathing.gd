extends Node


class pathnode:
	var col = 20
	var parent
	var pos
	var g = 0
	var h = 0
	var f = 0

	func _init(pparent, pnode):
		parent = pparent
		pos = pnode

	func set_h(destination):
		h = pos.distance_squared_to(destination)
	
	func get_routes():
		var r = []
		var pos_center = pos+G.V_HALF
		var left = G.tool.raycast(pos_center, Vector3.LEFT, 1, col) == null
		var right = G.tool.raycast(pos_center, Vector3.RIGHT, 1, col) == null
		var up = G.tool.raycast(pos_center, Vector3.FORWARD, 1, col) == null
		var down = G.tool.raycast(pos_center, Vector3.BACK, 1, col) == null
		var above = G.tool.raycast(pos_center, Vector3.UP, 1, col) == null
		if left:
			r.append(Vector3.LEFT)
		else:
			if above:
				var aabove = G.tool.raycast(pos_center+Vector3.LEFT, Vector3.UP, 1, col) == null
				if aabove:
					r.append(Vector3(-1, 1, 0))
		if right:
			r.append(Vector3.RIGHT)
			if above:
				var aabove = G.tool.raycast(pos_center+Vector3.RIGHT, Vector3.UP, 1, col) == null
				if aabove:
					r.append(Vector3(1, 1, 0))
		if up:
			r.append(Vector3.FORWARD)
			if left:
				r.append(Vector3(-1, 0, -1))
			if right:
				r.append(Vector3(1, 0, -1))
			if above:
				var aabove = G.tool.raycast(pos_center+Vector3.FORWARD, Vector3.UP, 1, col) == null
				if aabove:
					r.append(Vector3(0, 1, -1))
		if down:
			r.append(Vector3.BACK)
			if left:
				r.append(Vector3(-1, 0, 1))
			if right:
				r.append(Vector3(1, 0, 1))
			if above:
				var aabove = G.tool.raycast(pos_center+Vector3.BACK, Vector3.UP, 1, col) == null
				if aabove:
					r.append(Vector3(0, 1, 1))
		return r


var _unit
var target
var _chase = 11
var _timeout = 0
var _max_timeout = 1
var open = null
var closed = []
var closest = null
var result = []
var next_reset = 0
var heuristic_threshold = 0
var out_of_reach = false
var reached = false


func set_unit(unit):
	_unit = unit
	out_of_reach = false


func iterate(node):
	var index = 0
	for k in range(open.size()):
		var v = open[k]
		if v.f < node.f:
			index = k
			node = v
	open.pop_at(index)
	closed.append(node)
	var achieved = node.pos.distance_squared_to(target)
	if achieved <= 1:
		return node
	elif achieved < closest.pos.distance_squared_to(target):
		closest = node
	var options = node.get_routes()
	for route in options:
		var new = pathnode.new(node, node.pos + route)
		new.g = node.g + 1
		new.set_h(target)
		new.f = new.h + new.g
		if new.h < heuristic_threshold:
			open.append(new)


func check_loop(loop, pos):
	for i in loop:
		if i.pos == pos:
			return i


func perform(_delta):
	if !result.is_empty():
#		debug_trace()
		var next = result[0] + G.V2_HALF
		if _unit.position.distance_squared_to(next) <= .1:
			result.pop_front()
		else: 
			_unit.procedure.walk_toward(next)
			_timeout += _delta
			if _timeout >= _max_timeout:
				next_reset = 0
				result = []
				_timeout = 0
	else:
		_unit.procedure.stop_walk()
		on_turn()


func on_turn():
	var diff = _unit.position.distance_squared_to(target)
	if diff > 1:
		reached = false
		out_of_reach = false
		var done = null
		if next_reset == 0:
			reset()
			next_reset = 1
		else:
			next_reset += 1
		for _times in range(4):
			if open:
				done = iterate(open[0])
				if done != null:
					break
			else:
				break
		if done == null and next_reset > _chase:
			out_of_reach = true
			done = closest
		if done:
			next_reset = 0
			result = [done.pos]
			while done.parent:
				done = done.parent
				if _unit.position.floor() == done.pos:
					break
				result.insert(0, done.pos)
	else:
		reached = true
		result = [target]


func reset():
	var dist = _unit.position.distance_squared_to(target) 
	heuristic_threshold = dist * 2 + 2
	open = [pathnode.new(null, _unit.position.floor())]
	closed = []
	closest = open[0]


func debug_trace():
	if G.frame % 16 == 0:
		for i in result:
			G.stock.make_particle(i, "demolish")
