extends "./pilot.gd"


func _ready():
	super()
	melee_range = _unit.data.get("range")
	if _unit.get_type() == 1:
		if melee_range == null:
			var aabb = _unit.held_item_model.mesh.get_aabb()
			melee_range = -aabb.position.z
		attack_function = commence_use
	else:
		if melee_range == null:
			melee_range = _unit.size.z / 2
		attack_function = commence_tackle


func get_attack_range():
	var attack_range = _unit.data.get("range")
	if attack_range == null:
		var aabb = _unit.held_item_model.mesh.get_aabb()
		return -aabb.position.z * .5 + _unit.procedure.speed * .6
	return attack_range


func commence_use():
	_unit.procedure.face_front()
	_unit.procedure.use()


func commence_tackle():
	var atkspd = _unit.data.get("delay", 2)
	if _unit.action.set_next("delay", atkspd):
		_unit.animator.play("tackle")
