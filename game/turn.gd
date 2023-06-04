extends Node

var takers
var timees = []
var turn_idx = 0
var _frame = 0


func _init():
	clear()


func _process(delta):
	_frame += delta
	if _frame >= .25:
		_frame -= .25
		on_tick()


func clear():
	takers = [[],[],[],[],[],[],[],[]]


func has(p):
	for i in takers:
		if p in i:
			return true
	return false


func add(p):
	var min_taker_size = 999
	var min_taker = 0
	for i in range(takers.size()):
		var taker = takers[i]
		var taker_size = taker.size()
		if taker_size < min_taker_size:
			min_taker = i
			min_taker_size = taker_size
	takers[min_taker].append(p)


func remove(p):
	for i in takers:
		var index = i.find(p)
		if index != -1:
			i.remove_at(index)
			return index


func on_tick():
	var taker = takers[turn_idx]
	for i in range(taker.size()-1, -1, -1):
		var turnee = taker[i]
		if !turnee.call():
			taker.remove_at(i)
	turn_idx = _increment_index(turn_idx)


func add_timee(obj):
	for i in range(timees.size()):
		var timed = timees[i]
		if timed[0] == obj[0]:
			timed[1] = obj[1]
			return
	timees.append(obj)


func remove_timee(obj):
	for i in range(timees.size()):
		var timed = timees[i]
		if timed[0] == obj:
			timees.remove(i)
			return


func _increment_index(idx):
	idx += 1
	if idx >= len(takers):
		idx = 0
	return idx
