extends Node

const Pathing = preload("res://game/units/ai/pathing.gd")

var _pathing = Pathing.new()
var _ai_attack = Callable(self, "_do_attack")
var _from
var _to
var _dist = 999
var task
var _approach_range = 8
var _melee_range = 15
var in_range = false
var priority = 5
@onready var _unit = get_parent()


func _ready():
	_unit.camera = _unit
	_pathing.set_unit(_unit)
	_unit.action.bind("attack", Callable(self, "_attack"))
	_unit.forward = -_unit.get_transform().basis.z.normalized()


func _physics_process(_delta):
	if task != null:
		task.call(_delta)
	if in_range:
		_from = _unit.get_head()
		_to = G.you.get_head()
		_unit.forward = _from.direction_to(_to)
		_dist = _from.distance_squared_to(_to)
		if _dist > _approach_range:
			if priority > 2 and perceive():
				task = _ai_attack
				priority = 1
	_unit.action.on_process(_delta)


func perceive():
	var prop = G.tool.raycast(_from, _unit.forward, sqrt(_dist), 2)
	return prop == null


func _do_attack(_delta):
	if _dist <= _melee_range:
		var hitvoxel = G.tool.raycast(_from, _to, _dist, 8)
		if hitvoxel == null:
			_unit.procedure.stop_walk()
			_unit.procedure.use()
		else:
			_pathing.target = G.you.position.floor()
			_pathing.perform(_delta)
	elif _dist <= _approach_range:
		var to = G.you.position
		_unit.procedure.walk_toward(to)
	else:
		_pathing.target = G.you.position.floor()
		_pathing.perform(_delta)
