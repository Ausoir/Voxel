extends Node

const Laser = preload("res://game/item/weapon/projectile/laser.tscn")
const Bomb = preload("./bomb.tscn")
const Summons = ["bunny", "squirrel", "bat", "rat"]
const RaiseDeads = ["skeletal warrior", "skeletal ranger", "skeletal dog"]
var _unit
var _param
var _casting
var data = {}


func set_unit(p):
	_unit = p
	_unit.attacked.connect(on_hit)
	_unit.wait.connect(on_wait)
	_unit.kill.connect(on_kill)


func on_touch():
	if _unit.buffs.has("silence"):
		return false
	if !perform("summon", "capture"):
		if !perform("earth"):
			if !perform("sleep"):
				if !perform("bomb"):
					if !perform("psychic"):
						return false
	return true

func on_wait():
	if !perform("blood"):
		if !perform("bow"):
			if !perform("summon"):
				perform("vision")
				perform("nighteye")
				perform("camouflage")

func on_hit(_dmg):
	perform("warrior")

func on_attack(_victim):
	_param = _victim
	perform("vampire")
	perform("goblin")

func on_ability():
	if !perform("metal"):
		if !perform("heal"):
			if !perform("venom"):
				if !perform("divinity"):
					if !perform("shadow"):
						if !perform("polymorph"):
							return

func on_kill(_victim):
	_param = _victim
	perform("harvest")
	if !perform("raise"):
		if !perform("lethality"):
			return

func on_cast():
	if _casting != null:
		_casting.call()


func perform(ess, fn=null):
	if _unit.has_essence(ess):
		if fn == null:
			fn = ess
		if fn == "warrior":
			if _unit.health < _unit.data.health / 2:
				recover(3, 20)
				return true
			return false
		elif fn == "metal":
			return metal()
		elif fn == "blood":
			return sublimation()
		elif fn == "vision":
			return xray_vision()
		elif fn == "nighteye":
			return night_vision()
		elif fn == "harvest":
			G.stock.make_particle(_unit.position, "heal")
			recover(int(_unit.get_prof("necromancy")/3) + 1, 20)
			return true
		elif fn == "venom":
			return venom(7)
		elif fn == "lethality":
			_unit.buffs.add("lethality", 30)
			G.sfx.play("rip", _unit.position)
			return true
		elif fn == "capture":
			capture()
		elif fn == "bow":
			return craft_arrows()
		elif !_unit.buffs.has("exhaustion"):
			match fn:
				"earth":
					return passwall()
				"bomb":
					return plant_bomb()
				"heal":
					if _unit.health < _unit.data.health / 2:
						if _unit.req_mana(1):
							G.sfx.play("buff_heal", _unit.position)
							G.stock.make_particle(_unit.position, "heal")
							recover(_unit.get_prof("aura") + 3, 20)
							return true
						return false
					else:
						return heal_ready()
				"psychic":
					return psychic()
				"sleep":
					return sleep_ready()
				"camouflage":
					return hide()
				"divinity":
					return invulnerability()
				"summon":
					return summon()
				"shadow":
					return invisibility()
				"goblin":
					return slow(3)
				"wind":
					return fly()
				"polymorph":
					return polymorph()
				"raise":
					return raise()
				"vampire":
					if _unit.mana > 1:
						if recover(1, 8):
							_unit.req_mana(1)
							_unit.emit_signal("special", "necromancy", 1)
							return true
					return false
	return false


func fly():
	var aura = _unit.get_prof("aura")
	if aura > 2 or _unit.req_mana(1):
		_unit.animator.play("jump_ready")
		var forward = -_unit.camera.basis.z.normalized()
		_unit.velocity += forward * (16+aura)
		_unit.action.set_next("special", 0.8 - aura*.1)
		_unit.buffs.add("exhaustion", max(1, 8 - aura))
		_unit.emit_signal("special", "aura", 1)
	return true


func slow(p):
	_param.buffs.add("poison", p-1)
	_param.buffs.add("slow", p)
	G.sfx.play("buff_slow", _unit.position)
	return true


func venom(p):
	if !_unit.buffs.has("venomous"):
		_unit.buffs.add("venomous", p)
		G.sfx.play("buff_ripple", _unit.position)
		return true
	return false


func raise():
	if _unit.req_mana(1):
		var creature = G.rng.pick(RaiseDeads)
		if _unit.get_prof("necromancy") < 3:
			_unit.buffs.add("exhaustion", 2)
		var at = _param.position
		G.sfx.play("summon", _unit.position)
		G.stock.make_particle(at, "summon")
		var new = G.stock.make_any_unit(G.stock, at, creature)
		G.stock.attach_ai(new, "ally")
		return true
	return false


func capture():
	var origin = _unit.get_center()
	var hits = G.tool.collide_prop_by_shape(origin + _unit.forward, 1, 5)
	if !hits.is_empty():
		for hit in hits:
			var _item = hit.collider.get_parent()
			if _item.get("buffs") != null and _item.health <= 0:
				if _unit.req_mana(1):
					_unit.data["summon"] = _item.sid
					_item.remove()
					G.stock.make_particle(_item.position, "level")
					G.sfx.play("summon", _item.position + Vector3(0, .1, 0))
					_unit.emit_signal("special", "psych", 1)
					_unit.action.set_next("idle", .5)
					return true
	return false


func summon():
	var ally = data.get("summon")
	var summonname = _unit.data.get("summon")
	if summonname != null and (ally == null or ally.health <= 0):
		G.sfx.play("summon", _unit.position)
		G.stock.make_particle(_unit.position, "summon")
		_unit.buffs.add("exhaustion", 30)
		var new = G.stock.make_any_unit(G.stock, _unit.position, summonname)
		G.stock.attach_ai(new, "ally")
		data["summon"] = new
		return true
	return false


func polymorph():
	if _unit.buffs.has("polymorph"):
		_unit.buffs.set_duration("polymorph", 0)
	elif _unit.health > 1:
		if _unit == G.you:
			G.player.get_node("Cam").zoom_distance(2)
		G.sfx.play("cast_water", _unit.position)
		_unit.buffs.add("morph", -1)
		return true
	elif _unit == G.you:
		G.ui.msg("Health too low...")
	return false


func recover(regen, cd):
	if !_unit.buffs.has("regeneration cooldown"):
		_unit.buffs.add("regeneration", regen)
		_unit.buffs.add("regeneration cooldown", cd)
		return true
	return false


func metal():
	var hand = _unit.procedure.hand
	var hits = hand.get_interact_object(_unit)
	if !hits.is_empty():
		var _item = hits.collider.get_parent()
		var dmg = _item.base.data.get("damage", 0)
		_unit.buffs.add("clarity", G.rng.rir(min(dmg, _unit.get_prof("earth")), dmg))
		_item.remove()
		_unit.emit_signal("special", "earth", 1)
		return true
	return false


func sublimation():
	if _unit.mana == 0:
		_unit.mana = 1
		_unit.take_hit(5)
		_unit.buffs.add("clarity", int(_unit.get_prof("necromancy")/2))
		_unit.emit_signal("special", "necromancy", 0.1)
		return true
	return false


func hide():
	if !_unit.buffs.has("invisible"):
		G.sfx.play("fade", _unit.position)
	_unit.buffs.add("invisible", 1)


func invisibility():
	if _unit.req_mana(1):
		if !_unit.buffs.has("invisible"):
			G.sfx.play("fade", _unit.position)
			_unit.emit_signal("special", "aura", 1)
			_unit.buffs.add("invisible", 2+_unit.get_prof("aura"))
			return true
	return false


func invulnerability():
	if _unit.req_mana(2):
		if !_unit.buffs.has("invincible"):
			G.sfx.play("buff_ripple", _unit.position)
			_unit.emit_signal("special", "aura", 2)
			_unit.buffs.add("invincible", 8+_unit.get_prof("aura"))
			return true
	return false


func psychic():
	if _unit.mana >= 1:
		var anim_name = "blast"
		var animation = _unit.animator.get_animation(anim_name)
		if animation != null:
			var anim_dur = animation.get_length()
			_unit.animator.seek(0, true)
			_unit.animator.play(anim_name)
			_unit.action.set_next("use", anim_dur)
			_unit.action.show_progress = true
			_unit.action.cancelable = true
			G.sfx.play("cast_psych", _unit.position)
			_casting = psychic_shoot
			return true
	return false


func psychic_shoot():
	if !_unit.buffs.has("exhaustion"):
		_unit.req_mana(1)
	var rocket = Laser.instantiate()
	rocket.damage = 6 + _unit.get_prof("psych")
	rocket.position = _unit.get_center()
	G.stock.add_child(rocket)
	var spread = 0.7 / (2 + _unit.get_prof("psych"))
	var projectile_direction = G.rng.v3_spread(spread,spread,spread) + _unit.forward
	rocket.set_direction(projectile_direction)
	rocket.shooter = _unit
	_unit.action.set_next("idle", .5)
	_unit.buffs.add("exhaustion", max(1, 6 - _unit.get_prof("psych")))
	_unit.emit_signal("special", "psych", .25)
	return true


func sleep_ready():
	if _unit.mana >= 1:
		var origin = _unit.get_center()
		var hits = G.tool.collide_prop_by_line(origin, origin + _unit.forward * 2, 4)
		if !hits.is_empty():
			var _item = hits.collider.get_parent()
			if _item.get("buffs") != null:
				var anim_name = "shoot"
				var animation = _unit.animator.get_animation(anim_name)
				if animation != null:
					var speed = 2.5
					var anim_dur = animation.get_length() * (1 / speed)
					_unit.animator.seek(0, true)
					_unit.animator.play(anim_name, .1, speed)
					_unit.action.set_next("use", anim_dur)
					_unit.action.show_progress = true
					_unit.action.cancelable = true
					G.sfx.play("cast_psych", _unit.position)
					_casting = sleep_shoot
					return true
	return false


func sleep_shoot():
	var origin = _unit.get_center()
	var hits = G.tool.collide_prop_by_line(origin, origin + _unit.forward * 2, 4)
	if !hits.is_empty():
		var _item = hits.collider.get_parent()
		if _item.get("buffs") != null:
			if _unit.req_mana(1):
				_item.buffs.add("sleep", _unit.get_prof("psych") * 4 + 4)
				G.stock.make_particle(origin, "dodge")
				_unit.emit_signal("special", "psych", 1)
				_unit.action.set_next("idle", .5)
				return true
	return false


func heal_ready():
	if _unit.mana >= 1:
		var origin = _unit.get_center()
		var hits = G.tool.collide_prop_by_line(origin, origin + _unit.forward * 2, 4)
		if !hits.is_empty():
			var _item = hits.collider.get_parent()
			if _item.get("buffs") != null:
				var anim_name = "shoot"
				var animation = _unit.animator.get_animation(anim_name)
				if animation != null:
					var speed = 0.3
					var anim_dur = animation.get_length() * (1 / speed)
					_unit.animator.seek(0, true)
					_unit.animator.play(anim_name, .1, speed)
					_unit.action.set_next("use", anim_dur)
					_unit.action.show_progress = true
					_unit.action.cancelable = true
					G.sfx.play("cast_psych", _unit.position)
					_casting = heal_shoot
					return true
	return false


func heal_shoot():
	var origin = _unit.get_center()
	var hits = G.tool.collide_prop_by_line(origin, origin + _unit.forward * 2, 4)
	if !hits.is_empty():
		var _item = hits.collider.get_parent()
		if _item.get("buffs") != null:
			if _unit.req_mana(1):
				_unit.emit_signal("special", "aura", 1)
				_item.buffs.add("regeneration", 5+_unit.get_prof("aura")*2)
				_item.buffs.add("regeneration cooldown", 20)
				G.sfx.play("buff_heal", origin)
				G.stock.make_particle(origin, "heal")
				_unit.action.set_next("idle", .5)
				return true
	return false


func plant_bomb():
	var hit = G.tool.raycast(_unit.camera.global_position, _unit.forward, 1.5, 4)
	if hit != null:
		if _unit.req_mana(2):
			_unit.emit_signal("special", "earth", 2)
			var bomb = Bomb.instantiate()
			var dest = hit.previous_position
			bomb.position = dest
			bomb.shooter = _unit
			bomb.damage = 9
			G.stock.add_child(bomb)
			_unit.buffs.add("exhaustion", 10)
			return true
	return false


func xray_vision():
	if _unit.health >= _unit.data.health:
		_unit.buffs.add("vision", 3)
		return true
	return false


func night_vision():
	_unit.buffs.add("nighteye", _unit.get_prof("psych") * 7 + 10)
	return true


func craft_arrows():
	if _unit.get_type() == 1:
		var ammo = _unit.equipment.find_item_by_data("ammo", "bow")
		if ammo == null:
			var item = G.stock.make_item("makeshift arrows:8")
			G.sfx.play("craft", _unit.position)
			if !_unit.equipment.pickup(item):
				item.drop(_unit)
			return true
	return false


func passwall():
	if _unit == G.you:
		var cardinal = G.tool.cardinalize(_unit.forward)
		var dest = _unit.position.floor() + G.V2_HALF + cardinal * 2
		if G.tool.get_voxel(dest) == 0 and G.tool.get_voxel(dest + Vector3.UP) == 0:
			_unit.emit_signal("special", "earth", 0.1, 2)
			dest += cardinal * .5
			_unit.action.set_next("passwall", 3, G.you.camera.set_override.bind(null))
			_unit.action.on_tick = passwall_tick.bind(_unit, dest)
			G.you.camera.zoom_distance(1)
			G.you.camera.set_override(G.you.camera.position)
			_unit.buffs.add("exhaustion", max(1, 8 - _unit.get_prof("earth")))
			_unit.start_flash(Color.SADDLE_BROWN)
			G.sfx.play("cast_water", _unit.position)
			return true
	return false
func passwall_tick(_user, to):
	_user.position = _user.position.lerp(to, 0.01)

