extends Node

const Pathing = preload("res://game/units/ai/pathing.gd")

var _pathing = Pathing.new()
var _path = Callable(self, "_do_path")
var _attack = Callable(self, "_do_attack")
var _from
var _to
var _dist = 999
var task
var in_range = false
var priority = 5
@onready var _unit = get_parent()


func _ready():
	_unit.camera = _unit
	_pathing.set_unit(_unit)
	_unit.action.bind("tackle", Callable(self, "_tackle"))
	_unit.forward = -_unit.get_transform().basis.z.normalized()


func set_task(p):
	if p == _path:
		priority = 2
	elif p == _attack:
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
		if _dist > 3:
			if priority > 2 and perceive():
				set_task(_path)
		elif priority > 1:
			_unit.procedure.stop_walk()
			set_task(_attack)
	_unit.action.on_process(_delta)


func _tackle():
	_unit.animator.play("tackle")
#	G.stock.make_debris(G.you.position, 8)
#	G.stock.make_particle(G.you.position, "explosion")


func _tackle_end():
	pass


func perceive():
	var prop = G.tool.raycast(_from, _unit.forward, 16, 4)
	return prop == null


func _do_path(_delta):
	_pathing.target = G.you.position.floor()
	_pathing.perform(_delta)


func _do_attack(_delta):
	_unit.action.set_next("tackle", 2.5, Callable(self, "_tackle_end"))
	_unit.procedure.face_front()
	if _dist >= 3:
		set_task(_path)

