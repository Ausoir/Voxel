extends Node

const Pathing = preload("res://game/units/ai/pathing.gd")
const APPROACH_RANGE = 3

var _pathing = Pathing.new()
var _from
var _to
var _dist = 999
var task
var melee_range = 2
var in_range = false
var priority = 5
@onready var _unit = get_parent()


func _ready():
	_unit.camera = _unit
	_pathing.set_unit(_unit)
	_unit.forward = -_unit.get_transform().basis.z.normalized()


func _physics_process(_delta):
	if task != null:
		task.call(_delta)
	if in_range:
		_from = _unit.get_head()
		_to = G.you.get_head()
		_unit.forward = _from.direction_to(_to)
		_dist = _from.distance_to(_to)
		if _dist > APPROACH_RANGE:
			if priority > 2 and perceive():
				task = _do_attack
				priority = 1
	_unit.action.on_process(_delta)


func perceive():
	var prop = G.tool.raycast(_from, _unit.forward, _dist, 2)
	return prop == null


func _do_attack(_delta):
	pass
