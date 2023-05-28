extends "./pilot.gd"


func _ready():
	super()
	melee_range = get_attack_range()


func get_attack_range():
	var aabb = _unit.held_item_model.mesh.get_aabb()
	return -aabb.position.z * .5


func _do_attack(_delta):
	if _dist <= melee_range:
		var hitvoxel = G.tool.raycast(_from, _to, _dist, 8)
		if hitvoxel == null:
			_unit.procedure.stop_walk()
			_unit.procedure.use()
		else:
			_pathing.target = G.you.position.floor()
			_pathing.perform(_delta)
	elif _dist <= APPROACH_RANGE:
		var to = G.you.position
		_unit.procedure.walk_toward(to)
	else:
		_pathing.target = G.you.position.floor()
		_pathing.perform(_delta)
