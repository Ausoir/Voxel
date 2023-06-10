extends "../item.gd"

const Bullet = preload("./projectile/bullet.tscn")
const Laser = preload("./projectile/laser.tscn")
const Arrow = preload("./projectile/arrow.tscn")
var _projectile
var _times = 1


func use(_user: Node3D):
	var anim_name = "shoot"
	var animation = _user.animator.get_animation(anim_name)
	if animation != null:
		_times = 1
		var weapon_type = data.get("type", "bow")
		_user.procedure.speedmod = 0
		if weapon_type == "firearm" and _user.has_essence("firearm"):
			_user.procedure.speedmod = .8
		elif weapon_type == "evocation" and _user.has_essence("evocation"):
			anim_name = "shoot2"
			animation = _user.animator.get_animation(anim_name)
			_times = 2
		var speed = data.get("speed", 1.0)
		var anim_dur = animation.get_length() * (1 / speed)
		_user.animator.stop()
		_user.animator.play(anim_name, .1, speed)
		_user.action.force_set_next("use", anim_dur - .1)
		_user.action.show_progress = true
		_user.action.cancelable = true


func on_held(_user):
	_user.attack.connect(on_shoot.bind(_user))
	var proj = data.get("type", "bow")
	if proj == "firearm":
		_projectile = Bullet
	elif proj == "bow":
		_projectile = Arrow
	elif proj == "evocation":
		_projectile = Laser


func on_unheld(_user):
	_user.attack.disconnect(on_shoot)


func on_shoot(_user: Node3D):
	var from = _user.get_item_position()
	var held_item = _user.held_item_model
	var toward = -held_item.get_global_transform().basis.z
	var item_length = -held_item.mesh.get_aabb().position.z
	var hitvoxel = G.tool.raycast(from, toward, item_length, 4)
	if hitvoxel == null:
		var weapon_type = data.get("type", "bow")
		var inflict = data.get("inflict", [])
		var proj_speed = data.get("power", 15)
		var damage = data.get("damage", 1)
		var spread = data.get("spread", 0)
		var rocket = _projectile.instantiate()
		if _user == G.you:
			if weapon_type == "evocation":
				if !_user.req_mana(data.get("manause", 1)):
					G.ui.msg("Out of mana!")
					return
				rocket.radius = data.get("radius", 2)
			else:
				var ammo = _user.equipment.find_item_by_data("ammo", weapon_type)
				if ammo == null or !ammo.spend(_user):
					G.ui.msg("Out of ammunition!")
					return
				if "power" in ammo.data:
					proj_speed = ammo.data.power
				if "damage" in ammo.data:
					damage += ammo.data.damage
				if "spread" in ammo.data:
					spread = max(0, spread + ammo.data.spread)
				inflict = inflict.duplicate() + ammo.data.get("inflict", [])
		var damage_roll = G.rng.damage_roll(damage, _user.get_prof(weapon_type))
		rocket.noise = data.get("noise", 4)
		G.tool.set_sound(_user.position, rocket.noise / 2)
		rocket.backstab = data.get("backstab", 2)
		rocket.damage = damage_roll
		rocket.inflict = inflict
		rocket.position = held_item.global_position + toward * item_length
		rocket.shooter = _user
		G.stock.add_child(rocket)
		var projectile_direction = G.rng.v3_spread(spread,spread,spread) + _user.forward
		rocket.speed = proj_speed
		rocket.set_direction(projectile_direction)
		rocket.on_attack = on_attack.bind(_user)
		
		_times -= 1
		if _times == 0:
			var delay = data.get("delay", .5)
			_user.action.set_next("idle", delay)


func on_attack(_victim, _user):
	var weapon_type = data.get("type", "bow")
	_user.emit_signal("weapon", weapon_type, _victim, data.get("damage", 1))
