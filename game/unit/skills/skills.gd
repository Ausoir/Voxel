extends Node

const Laser = preload("res://game/item/weapon/projectile/laser.tscn")
const Bomb = preload("./bomb.tscn")
var _unit
var _param


func set_unit(p):
	_unit = p
	_unit.attacked.connect(on_hit)
	_unit.wait.connect(on_wait)


func on_touch():
	if !perform("earth"):
		if !perform("bomb"):
			if !perform("psychic"):
				return false
	return true

func on_wait():
	perform("blood")
	if !perform("vision"):
		perform("nighteye")

func on_hit(_dmg):
	perform("warrior")

func on_attack(_victim):
	_param = _victim
	perform("vampire")
	perform("goblin")

func on_ability():
	if !perform("metal"):
		perform("shadow")


func perform(ess):
	if _unit.has_essence(ess):
		if ess == "warrior":
			return recover(3, 30)
		elif ess == "metal":
			return metal()
		elif ess == "blood":
			return sublimation()
		elif ess == "vision":
			return xray_vision()
		elif ess == "nighteye":
			return night_vision()
		elif !_unit.buffs.has("exhaustion"):
			if ess == "earth":
				return passwall()
			elif ess == "bomb":
				return plant_bomb()
			elif ess == "psychic":
				return psychic()
			elif ess == "shadow":
				return invisibility()
			elif ess == "goblin":
				return slow(3)
			elif ess == "vampire":
				if req_mana(1):
					return recover(1, 8)
	return false


func slow(p):
	_param.buffs.add("slow", p)
	G.sfx.play("buff_slow", _unit.position)


func recover(regen, cd):
	if !_unit.buffs.has("regeneration cooldown"):
		_unit.buffs.add("regeneration", regen)
		_unit.buffs.add("regeneration cooldown", cd)


func metal():
	var hand = _unit.procedure.hand
	var hits = hand.get_interact_object(_unit)
	if !hits.is_empty():
		var _item = hits.collider.get_parent()
		var dmg = _item.base.data.get("damage", 0)
		_unit.buffs.add("clarity", G.rng.rir(min(dmg, _unit.get_prof("earth")), dmg))
		_item.remove()
		_unit.emit_signal("special", "earth")


func sublimation():
	if _unit.mana == 0:
		_unit.take_hit(5)
		_unit.buffs.add("clarity", 2 + _unit.get_prof("necromancy"))
		_unit.emit_signal("special", "necromancy")


func invisibility():
	if req_mana(max(1, 3 - _unit.get_prof("aura"))):
		if !_unit.buffs.has("invisibility"):
			G.sfx.play("fade", _unit.position)
		_unit.buffs.add("invisibility", 3)
		_unit.emit_signal("special", "aura")


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
			_unit.buffs.add("exhaustion", max(1, 8 - _unit.get_prof("psych")))
			G.sfx.play("cast_psych", _unit.position)
			_unit.emit_signal("special", "psych")
			if !_unit.attack.is_connected(psychic_shoot):
				_unit.attack.connect(psychic_shoot)


func psychic_shoot():
	if req_mana(1):
		var rocket = Laser.instantiate()
		rocket.damage = 5 + _unit.get_prof("psych")
		rocket.position = _unit.get_center()
		G.stock.add_child(rocket)
		var spread = .15
		var projectile_direction = G.rng.v3_spread(spread,spread,spread) + _unit.forward
		rocket.set_direction(projectile_direction)
		_unit.action.set_next("idle", .5)
		_unit.buffs.add("clarity", G.rng.rir(0, 3))


func plant_bomb():
	var hit = G.tool.raycast(_unit.camera.global_position, _unit.forward, 1.5, 4)
	if hit != null:
		_unit.emit_signal("special", "psych")
		var bomb = Bomb.instantiate()
		var dest = hit.previous_position
		bomb.position = dest
		G.tool.set_voxel(dest, 3)
		G.stock.add_child(bomb)
		_unit.buffs.add("exhaustion", 10)
		return true


func xray_vision():
	_unit.buffs.add("vision", 0)


func night_vision():
	_unit.buffs.add("nighteye", _unit.get_prof("psych"))


func passwall():
	if _unit == G.you:
		var cardinal = G.tool.cardinalize(_unit.forward)
		var dest = _unit.position.floor() + G.V2_HALF + cardinal * 2
		if G.tool.get_voxel(dest) == 0 and G.tool.get_voxel(dest + Vector3.UP) == 0 and G.tool.get_voxel(dest + Vector3.DOWN) != 0:
			_unit.emit_signal("special", "earth")
			dest += cardinal * .5
			_unit.action.set_next("passwall", 3, G.you.camera.set_override.bind(null))
			_unit.action.on_tick = passwall_tick.bind(_unit, dest)
			G.you.camera.zoom_distance(1)
			G.you.camera.set_override(G.you.camera.position)
			_unit.buffs.add("exhaustion", max(1, 8 - _unit.get_prof("earth")))
			_unit.start_flash(Color.SADDLE_BROWN)
			G.sfx.play("cast_water", _unit.position)
			return true
func passwall_tick(_user, to):
	_user.position = _user.position.lerp(to, 0.01)


func req_mana(p):
	if _unit.mana >= p:
		_unit.mana -= p
		return true
	return false

