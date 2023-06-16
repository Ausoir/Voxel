extends Node

const Pathing = preload("res://game/unit/ai/pathing.gd")
const APPROACH_RANGE = 6

var _pathing = Pathing.new()
var _from
var _to
var _dist = 999
var _frame = 0
var _timeout = 0
var _target
var _idle_task
var _wander_target
var _way_clear
var _detect_range = 16
var task
var melee_range = 2
var in_range = false
var priority = 5
var attack_function
@onready var _unit = get_parent()


func _ready():
	_unit.camera = _unit
	_unit.attacked.connect(on_attacked)
	_pathing.set_unit(_unit)


func _physics_process(_delta):
	_unit.motor = Vector3.ZERO
	if task != null:
		task.call(_delta)
	elif _idle_task != null:
		_idle_task.call(_delta)
	_frame += _delta
	if in_range:
		set_default_target()
		if _target != null:
			_update_target_params()
			if !_target.visible:
				if priority < 5:
					deaggro()
			elif priority > 2 and hear() or (_frame >= 0.5 and perceive()):
				aggro()
		elif priority < 5:
			deaggro()
	if _frame >= 0.5:
		_frame -= 0.5
		if priority == 1:
			_way_clear = G.tool.raycast(_from, _unit.forward, _dist, 8)
			if !in_range or _way_clear != null:
				_timeout += 1
			else:
				_timeout = 0
		else:
			if _wander_target != null:
				if G.rng.percent(.1):
					_wander_target = null
	if _timeout > 32:
		_timeout = 0
		deaggro()
	_unit.action.on_process(_delta)


func set_default_target():
	if _target == null:
		_target = G.you


func _update_target_params():
	if _unit.physics_process == _unit._fly_physics_process:
		_from = _unit.get_head()
		_to = _target.get_head()
	else:
		_from = _unit.position + _unit.COLLISION_CENTER
		_to = _target.position + _unit.COLLISION_CENTER
	_unit.forward = _from.direction_to(_to)
	_dist = _from.distance_to(_to) - _target.size.z/2
	_detect_range = 16 - _target.data.get("sneak", 0)


func deaggro():
	if priority == 1 and _idle_task == null:
		_idle_task = _wander
	_unit.procedure.stop_walk()
	priority = 5
	task = null
	_target = null
	_to = _from


func aggro():
	task = _chase
	priority = 1
	_unit.alert = true


func perceive():
	var dir_to = _unit.transform.basis.z.normalized()
	var angle = dir_to.dot(_unit.forward)
	if _dist <= _detect_range and angle > .2 + _unit.get_prof("ambush")*.05:
		var prop = G.tool.raycast(_from, _unit.forward, _dist, 2)
		return prop == null


func hear():
	return G.tool.get_sound(_unit.position)


func on_attacked(_dmg):
	_target = _unit.last_hitter
	if _target != null and _target.faction != _unit.faction:
		_update_target_params()
		aggro()


func _wander(_delta):
	if _wander_target == null:
		_wander_target = G.rng.rir(0, 8)
	else:
		if _wander_target > 3:
			_unit.procedure.stop_walk()
		else:
			var center = _unit.get_center()
			var dir = G.CARDINALS[_wander_target]
			var clear = G.tool.raycast(center, dir, 1, 4)
			if clear == null:
				var clear2 = G.tool.raycast(center + dir, Vector3.DOWN, 2, 4)
				if clear2 != null:
					_unit.procedure.walk_dir(dir.x, dir.z)
			else:
				var clear2 = G.tool.raycast(center, Vector3.UP, 1, 4)
				if clear2 == null:
					var clear3 = G.tool.raycast(center + Vector3.UP, dir, 1, 4)
					if clear3 == null:
						_unit.procedure.walk_dir(dir.x, dir.z)


func _search(_delta):
	if _wander_target == null:
		_wander_target = G.rng.rir(0, 3)
	else:
		var center = _unit.get_center()
		var dir = G.CARDINALS[_wander_target]
		var clear = G.tool.raycast(center, dir, 1, 4)
		if clear == null:
			var clear2 = G.tool.raycast(center + dir, Vector3.DOWN, 2, 4)
			if clear2 != null:
				_unit.procedure.walk_dir(dir.x, dir.z)
		else:
			var clear2 = G.tool.raycast(center, Vector3.UP, 1, 4)
			if clear2 == null:
				var clear3 = G.tool.raycast(center + Vector3.UP, dir, 1, 4)
				if clear3 == null:
					_unit.procedure.walk_dir(dir.x, dir.z)
		if _unit.motor == Vector3.ZERO:
			_wander_target = null


func _chase(_delta):
	if _unit.action.action == null and _unit.action.can_set():
		_unit.procedure.speedmod = 1
	if _way_clear != null:
		_pathing.set_target(_to)
		_pathing.perform(_delta)
	elif _dist <= APPROACH_RANGE:
		_unit.procedure.walk_toward(_to)
		if _dist <= melee_range:
			attack_function.call()
	else:
		_pathing.set_target(_to)
		_pathing.perform(_delta)

