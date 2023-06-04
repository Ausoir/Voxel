extends "../item.gd"

const Laser = preload("./projectile/laser.tscn")
const Arrow = preload("./projectile/arrow.tscn")
const Rocket = preload("./projectile/rocket.tscn")
var _projectile


func use(_user: Node3D):
	var anim_name = "shoot"
	var animation = _user.animator.get_animation(anim_name)
	if animation != null:
		var speed = data.get("speed", 1.0)
		var anim_dur = animation.get_length() * (1 / speed)
		_user.animator.stop()
		_user.animator.play(anim_name, .1, speed)
		_user.action.force_set_next("use", anim_dur * .5 - .1, use_callback.bind(_user))
		_user.action.show_progress = true
		_user.action.cancelable = true


func use_callback(_user):
	var delay = data.get("delay", 1)
	_user.action.force_set_next("idle", delay)


func on_held(_user):
	_user.attack.connect(on_shoot.bind(_user))
	var proj = data.get("projectile", "arrow")
	if proj == "laser":
		_projectile = Laser
	elif proj == "arrow":
		_projectile = Arrow
	elif proj == "rocket":
		_projectile = Rocket


func on_unheld(_user):
	_user.attack.disconnect(on_shoot)


func on_shoot(_user: Node3D):
	var from = _user.get_item_position()
	var held_item = _user.held_item_model
	var toward = -held_item.get_global_transform().basis.z
	var item_length = -held_item.mesh.get_aabb().position.z
	var hitvoxel = G.tool.raycast(from, toward, item_length, 8)
	if hitvoxel == null:
		var weapon_type = data.get("type", "bow")
		var inflict = data.get("inflict", [])
		var proj_speed = data.get("power", 20)
		if _user == G.you:
			if !G.you.has_essence("bow"):
				G.player.noise = data.get("noise", 3)
			var ammo = _user.equipment.find_item_by_data("ammo", weapon_type)
			if ammo == null or !ammo.spend(_user):
				G.ui.set_message("Out of arrows!")
				return
			if "power" in ammo.data:
				proj_speed = ammo.data.power
			inflict = inflict.duplicate() + ammo.data.get("inflict", [])
		var rocket = _projectile.instantiate()
		var damage = data.get("damage", 1)
		var damage_roll = G.rng.rir(min(damage, _user.get_prof(weapon_type)), damage)
		rocket.damage = damage_roll
		rocket.inflict = inflict
		rocket.position = held_item.global_position + toward * item_length
		G.stock.add_child(rocket)
		var spread = data.get("spread", 0)
		var projectile_direction = G.rng.v3_spread(spread,spread,spread) + _user.forward
		rocket.speed = proj_speed
		rocket.set_direction(projectile_direction)
		rocket.on_attack = on_attack.bind(_user)

		var delay = data.get("delay", .5)
		_user.action.set_next("idle", delay)


func on_attack(_victim, _user):
	var weapon_type = data.get("type", "bow")
	_user.emit_signal("weapon", weapon_type, _victim, data.get("damage", 1))
