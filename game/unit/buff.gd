static func get_buff(name):
	var r
	if name == "slow":
		r = Slow
	elif name == "sleep":
		r = Sleep
	elif name == "regeneration":
		r = Regeneration
	elif name == "clarity":
		r = Clarity
	elif name == "invisibility":
		r = Invisibility
	elif name == "stoneskin":
		r = Stoneskin
	elif name == "corrosion":
		r = Corrosion
	elif name == "daze":
		r = Daze
	elif name == "silence":
		r = Silence
	elif name == "poison":
		r = Poison
	elif name == "track":
		r = Track
	elif name == "nighteye":
		r = Nighteye
	elif name == "vision":
		r = Vision
	elif name == "flight":
		r = Flight
	else:
		r = Buff
	return r


class Buff:
	var _unit
	var name
	var duration = 0
	var sprite


	func _init(punit, pdur):
		_unit = punit
		duration = pdur


	func on_turn():
		if duration == 0:
			on_end()
			return false
		if duration > 0:
			duration -= 1
		return true


	static func req_met(_p):
		return true


	func get_description():
		return name.capitalize() + "\n"


	func on_start():
		pass
	func on_end():
		pass
	func on_stack(new_dur):
		duration = max(new_dur, duration)


class Slow extends Buff:
	func on_start():
		_unit.procedure.speed -= .2
	func on_end():
		_unit.procedure.speed += .2
	func get_description():
		return super() + "Movement speed slowed by 2."


class Sleep extends Buff:
	func on_start():
		_unit.alert = false
		if _unit.health > 0:
			_unit.animator.play("down")
			_unit.action.force_set_next("sleep", 9999)
			_unit.procedure.speedmod = 0
	func on_end():
		_unit.alert = true
		if _unit.health > 0:
			_unit.action.delay = 0
		_unit.procedure.speedmod = 1
	func get_description():
		return super() + "Wake when taking damage."


class Down extends Buff:
	func on_start():
		if _unit.health > 0:
			_unit.animator.play("down")
			_unit.action.force_set_next("sleep", 9999)
			_unit.procedure.speedmod = 0
	func on_end():
		if _unit.health > 0:
			_unit.action.delay = 0
		_unit.procedure.speedmod = 1
	func get_description():
		return super() + "Unable to act."


class Regeneration extends Buff:
	func on_turn():
		var max_hp = _unit.data.get("health", 1)
		_unit.health = min(_unit.health + 1, max_hp)
		_unit.show_healthbar()
		return super()
	func get_description():
		return super() + "Regenerate 1 health per second."


class Poison extends Buff:
	func on_turn():
		_unit.take_hit(1)
		return super()
	func get_description():
		return super() + "Lose 1 health per second."


class Clarity extends Buff:
	func on_start():
		G.stock.make_particle(_unit.get_head(), "clarity")
	func on_turn():
		var max_hp = _unit.data.get("mana", 1)
		var inc = max(1, int(max_hp * 0.08))
		_unit.mana = min(_unit.mana + inc, max_hp)
		return super()
	func get_description():
		return super() + "Regenerate 8% mana per second."


class Invisibility extends Buff:
	var interrupted = false
	func on_start():
		_unit.weapon.connect(on_interrupt)
		_unit.hide()
	func on_end():
		_unit.show()
	func get_description():
		return super() + "Become invisible."
	func on_interrupt(_type, _victim):
		duration = 0
		interrupted = true
	func on_stack(new_dur):
		if !interrupted:
			duration = max(new_dur, duration)


class Vision extends Buff:
	var mat = preload("res://game/environment/xray.tres")
	func on_start():
		if _unit == G.you:
			G.terrain.set_material_override(mat)
	func on_end():
		if _unit == G.you:
			G.terrain.set_material_override(null)
	func get_description():
		return super() + "Gain vision through walls. Vision distance scales with Psych."


class Nighteye extends Buff:
	func on_start():
		if _unit == G.you:
			G.env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			G.env.environment.ambient_light_color = Color.GREEN
			G.env.environment.ambient_light_energy = 4.0
	func on_end():
		if _unit == G.you:
			G.env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
	func get_description():
		return super() + "Gain vision through the darkness."


class Stoneskin extends Buff:
	func on_start():
		_unit.defense += 5
	func on_end():
		_unit.defense -= 5
	func get_description():
		return super() + "Negate incoming damage by 5."


class Corrosion extends Buff:
	func on_start():
		_unit.defense -= 3
	func on_end():
		_unit.defense += 3
	func get_description():
		return super() + "Increase all damage taken by 3."


class Daze extends Buff:
	func get_description():
		return super() + "Disables interation for the duration."


class Silence extends Buff:
	func get_description():
		return super() + "Disables abilities for the duration."


class Flight extends Buff:
	static func req_met(punit):
		return punit.physics_process == punit._walk_physics_process
	func on_start():
		_unit.physics_process = _unit._fly_physics_process
	func on_end():
		_unit.physics_process = _unit._walk_physics_process
	func get_description():
		return super() + "Fly."


class Track extends Buff:
	func get_description():
		return super() + "Teleport to safety when near death."

