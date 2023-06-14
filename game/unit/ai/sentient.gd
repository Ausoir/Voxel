extends "./pilot.gd"

var _attack_motion


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
		_attack_motion = _unit.data.get("attack", "tackle")
		if _attack_motion == "shoot":
			_unit.attack.connect(on_shoot)


func set_follow(who):
	_idle_task = follow.bind(who)


func get_attack_range():
	var attack_range = _unit.data.get("range")
	if attack_range == null:
		var aabb = _unit.held_item_model.mesh.get_aabb()
		return -aabb.position.z * .5 + _unit.procedure.speed * .5
	return attack_range


func commence_use():
	_unit.procedure.face_front()
	_unit.procedure.use()


func commence_tackle():
	var atkspd = _unit.data.get("delay", 2)
	if _unit.action.set_next("delay", atkspd):
		_unit.procedure.speedmod = 0.3
		_unit.animator.stop()
		_unit.animator.play(_attack_motion)


func follow(_delta, who):
	if _unit.action.action == null and _unit.action.can_set():
		_unit.procedure.speedmod = 1
		if is_instance_valid(who):
			_target = who
			_update_target_params()
			if _dist <= 2:
				_unit.procedure.stop_walk()
			else:
				_pathing.set_target(_to)
				_pathing.perform(_delta)
		else:
			_idle_task = null
		_target = null
	else:
		_unit.procedure.stop_walk()


func on_shoot():
	var projname = _unit.data.get("projectile")
	var projectile = G.stock.Projectiles[projname].instantiate()
	projectile.damage = _unit.data.get("damage", 5)
	projectile.inflict = _unit.data.get("inflict", [])
	projectile.position = _unit.get_center() + _unit.forward
	projectile.shooter = _unit
	G.stock.add_child(projectile)
	projectile.set_direction(_unit.forward)
