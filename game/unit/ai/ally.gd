extends "./sentient.gd"


func _ready():
	super()
	_idle_task = _follow


func set_default_target():
	if _target == null or _target.health <= 0:
		var center = _unit.get_center()
		var closest
		var closest_dist = 999999
		for enemy in G.player.enemies:
			var dist = enemy.position.distance_squared_to(_unit.position)
			if dist < closest_dist:
				var e = enemy.get_center()
				var dir = center.direction_to(e)
				var raycast = G.tool.raycast(center, dir, sqrt(dist), 4)
				if raycast == null:
					closest = enemy
					closest_dist = dist
		_target = closest


func _follow(_delta):
	if _unit.action.action == null and _unit.action.can_set():
		_unit.procedure.speedmod = 1
		_target = G.you
		_update_target_params()
		if _dist <= 3:
			_unit.procedure.stop_walk()
		elif _dist <= APPROACH_RANGE:
			_unit.procedure.walk_toward(_to)
		else:
			_pathing.target = _to.floor()
			_pathing.perform(_delta)
		_target = null
	else:
		_unit.procedure.stop_walk()


func perceive():
	return true

