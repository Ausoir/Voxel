extends Node

const Pathing = preload("res://game/units/ai/pathing.gd")

var _pathing = Pathing.new()
var _ai_path = Callable(self, "_do_path")
var _ai_attack = Callable(self, "_do_attack")
var _from
var _to
var _dist = 999
var task
var approach_range = 1.5
var in_range = false
var priority = 5
@onready var _unit = get_parent()


func _ready():
	_unit.camera = _unit
	_pathing.set_unit(_unit)
	_unit.action.bind("attack", Callable(self, "_attack"))
	_unit.forward = -_unit.get_transform().basis.z.normalized()


func set_task(p):
	if p == _ai_path:
		priority = 2
	elif p == _ai_attack:
		priority = 1
	task = p


func _physics_process(_delta):
	if task != null:
		task.call(_delta)
	if in_range:
		_from = _unit.get_head()
		_to = G.you.get_head()
		_unit.forward = _from.direction_to(_to)
		_dist = _from.distance_squared_to(_to)
		if _dist > approach_range:
			if priority > 2 and perceive():
				set_task(_ai_path)
		elif priority > 1:
			_unit.procedure.stop_walk()
			set_task(_ai_attack)
	_unit.action.on_process(_delta)


func perceive():
	var prop = G.tool.raycast(_from, _unit.forward, 16, 4)
	return prop == null


func _do_path(_delta):
	_pathing.target = G.you.position.floor()
	_pathing.perform(_delta)


func _do_attack(_delta):
	_unit.procedure.use()
	if _dist > approach_range:
		set_task(_ai_path)

