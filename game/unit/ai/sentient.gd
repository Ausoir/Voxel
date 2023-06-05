extends "./pilot.gd"


func _ready():
	super()
	melee_range = get_attack_range()


func get_attack_range():
	var attack_range = _unit.data.get("range")
	if attack_range == null:
		var aabb = _unit.held_item_model.mesh.get_aabb()
		return -aabb.position.z * .5
	return attack_range


func _do_attack(_delta):
	if _dist <= melee_range:
		var hitvoxel = G.tool.raycast(_from, _unit.forward, _dist, 10)
		if hitvoxel == null:
			_unit.procedure.stop_walk()
			_unit.procedure.use()
		else:
			_pathing.target = _to.floor()
			_pathing.perform(_delta)
	elif _dist <= APPROACH_RANGE:
		_unit.procedure.walk_toward(_to)
	else:
		_pathing.target = _to.floor()
		_pathing.perform(_delta)
