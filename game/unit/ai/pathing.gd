class pathnode:
	const UPRIGHT = Vector3(1, 0, -1)
	const UPLEFT = Vector3(-1, 0, -1)
	const DOWNRIGHT = Vector3(1, 0, 1)
	const DOWNLEFT = Vector3(-1, 0, 1)
	var col = 4
	var parent
	var pos
	var g = 0
	var h = 0
	var f = 0

	func _init(pparent, pnode):
		parent = pparent
		pos = pnode

	func set_h(destination):
		h = dist_to(destination)
#		h = pos.distance_to(destination)
	
	func dist_to(destination):
		var dx = abs(pos.x - destination.x)
		var dy = abs(pos.y - destination.y) * 3
		var dz = abs(pos.z - destination.z)
		return dx + dy + dz
		

	func get_routes():
		var r = []
		var pos_center = pos+G.V_HALF
		var left = G.tool.raycast(pos_center, Vector3.LEFT, 1, col) == null
		var right = G.tool.raycast(pos_center, Vector3.RIGHT, 1, col) == null
		var up = G.tool.raycast(pos_center, Vector3.FORWARD, 1, col) == null
		var down = G.tool.raycast(pos_center, Vector3.BACK, 1, col) == null
		var empty_above = G.tool.raycast(pos_center, Vector3.UP, 1, col) == null
		if left:
			r.append(Vector3.LEFT)
		elif empty_above:
			var above = pos_center + Vector3.UP
			var can_jump = G.tool.raycast(above, Vector3.LEFT, 1, col) == null
			if can_jump:
				r.append(Vector3(-1, 1, 0))
		if right:
			r.append(Vector3.RIGHT)
		elif empty_above:
			var above = pos_center + Vector3.UP
			var can_jump = G.tool.raycast(above, Vector3.RIGHT, 1, col) == null
			if can_jump:
				r.append(Vector3(1, 1, 0))
		if up:
			r.append(Vector3.FORWARD)
			if left and G.tool.raycast(pos_center, UPLEFT, 1, col) == null:
				r.append(UPLEFT)
			if right and G.tool.raycast(pos_center, UPRIGHT, 1, col) == null:
				r.append(UPRIGHT)
		elif empty_above:
			var above = pos_center + Vector3.UP
			var can_jump = G.tool.raycast(above, Vector3.FORWARD, 1, col) == null
			if can_jump:
				r.append(Vector3(0, 1, -1))
		if down:
			r.append(Vector3.BACK)
			if left and G.tool.raycast(pos_center, DOWNLEFT, 1, col) == null:
				r.append(DOWNLEFT)
			if right and G.tool.raycast(pos_center, DOWNRIGHT, 1, col) == null:
				r.append(DOWNRIGHT)
		elif empty_above:
			var above = pos_center + Vector3.UP
			var can_jump = G.tool.raycast(above, Vector3.BACK, 1, col) == null
			if can_jump:
				r.append(Vector3(0, 1, 1))
		return r


var _unit
var target
var _chase = 6
var _iterations = 6
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


func set_target(p):
	target = p.floor() + G.V2_HALF


func iterate(node):
	var index = 0
	for k in range(open.size()):
		var v = open[k]
		if v.f < node.f:
			index = k
			node = v
	open.pop_at(index)
	closed.append(node)
	var achieved = node.dist_to(target)
	if achieved <= 1:
		return node
	elif achieved < closest.dist_to(target):
		closest = node
	var options = node.get_routes()
	for route in options:
		var newpos = node.pos + route
		if check_loop(closed, newpos) == null:
			var new = pathnode.new(node, newpos)
			new.g = node.g + 1
			new.set_h(target)
			new.f = new.h + new.g
#			G.stock.make_particle(newpos + G.V2_HALF, "marker")
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
		_unit.procedure.walk_toward(next)
		if _unit.position.distance_squared_to(next) <= .1:
			_timeout = 0
			result.pop_front()
		else:
			_timeout += _delta
			if _timeout >= _max_timeout:
				next_reset = 0
				result = []
				_timeout = 0
	else:
		on_turn()


func on_turn():
	reached = false
	out_of_reach = false
	var done = null
	if next_reset == 0:
		reset()
		next_reset = 1
	else:
		next_reset += 1
	for _times in range(_iterations):
		if open:
			done = iterate(open[0])
			if done != null:
				break
		else:
			break
	if done == null and next_reset > _chase:
		out_of_reach = true
		done = closest
		next_reset = 0
	if done:
		result = [done.pos]
		while done.parent:
			done = done.parent
			if _unit.position.floor() == done.pos:
				break
			result.insert(0, done.pos)


func reset():
	var dist = _unit.position.distance_squared_to(target) 
	heuristic_threshold = dist * 2 + 2
	open = [pathnode.new(null, _unit.position.floor())]
	closed = []
	closest = open[0]


func debug_trace():
	for i in result:
		G.stock.make_particle(i + G.V2_HALF, "marker")
