extends Node

const Pathing = preload("res://game/unit/ai/pathing.gd")
const APPROACH_RANGE = 3

var _pathing = Pathing.new()
var _from
var _to
var _dist = 999
var _timeout = 0
var task
var melee_range = 2
var in_range = false
var priority = 5
@onready var _unit = get_parent()


func _ready():
	_unit.camera = _unit
	_pathing.set_unit(_unit)
	_unit.attacked.connect(on_attacked)


func _physics_process(_delta):
	_unit.motor = Vector3.ZERO
	if task != null:
		task.call(_delta)
	if in_range:
		_timeout = 0
		if !G.you.visible:
			if priority < 5:
				deaggro()
		else:
			_from = _unit.get_head()
			_to = G.you.get_head()
			_unit.forward = _from.direction_to(_to)
			_dist = _from.distance_to(_to)
			if priority > 2 and perceive():
				aggro()
	else:
		_timeout += _delta
		if _timeout > 8.0:
			deaggro()
	_unit.action.on_process(_delta)


func deaggro():
	_unit.alert = false
	_unit.procedure.stop_walk()
	priority = 5
	task = null
	_to = _from


func aggro():
	task = _do_attack
	priority = 1
	_unit.alert = true


func perceive():
	if _dist <= G.player.noise:
		return true
	var dir_to = _unit.transform.basis.z.normalized()
	var angle = dir_to.dot(_unit.forward)
	if angle > .5:
		var prop = G.tool.raycast(_from, _unit.forward, _dist, 2)
		return prop == null


func _do_attack(_delta):
	pass


func on_attacked(_dmg):
	aggro()
