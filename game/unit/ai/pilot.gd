extends Node

const Pathing = preload("res://game/unit/ai/pathing.gd")
const APPROACH_RANGE = 3

var _pathing = Pathing.new()
var _from
var _to
var _dist = 999
var _timeout = 0
var _target
var task
var melee_range = 2
var in_range = false
var priority = 5
var attack_function
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
			if _target == null:
				_target = G.you
			_update_target_params()
			if priority > 2 and perceive():
				aggro()
	else:
		_timeout += _delta
		if _timeout > 8.0:
			deaggro()
	_unit.action.on_process(_delta)


func _update_target_params():
	_from = _unit.get_head()
	_to = _target.get_head()
	_unit.forward = _from.direction_to(_to)
	_dist = _from.distance_to(_to)


func deaggro():
	_unit.alert = false
	_unit.procedure.stop_walk()
	priority = 5
	task = null
	_to = _from


func aggro():
	task = _chase
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


func on_attacked(_dmg):
	_target = _unit.last_hitter
	if _target != null:
		_update_target_params()
		aggro()


func _chase(_delta):
	if _unit.action.can_set():
		_unit.procedure.speedmod = 1
	if _dist <= melee_range:
		var hitvoxel = G.tool.raycast(_from, _unit.forward, _dist, 4)
		if hitvoxel == null:
			attack_function.call()
		else:
			_pathing.target = _to.floor()
			_pathing.perform(_delta)
	elif _dist <= APPROACH_RANGE:
		var to = G.you.position
		_unit.procedure.walk_toward(to)
	else:
		_pathing.target = _to.floor()
		_pathing.perform(_delta)
