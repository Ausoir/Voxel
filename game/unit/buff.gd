static func make_buff(unit, name, dur):
	var r
	var undefined = false
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
	else:
		r = Buff
		undefined = true
	r = r.new(unit, dur)
	r.name = name
	var path
	if undefined:
		path = str("ui/def_", name.replace(" ", "_"))
	else:
		path = str("ui/st_", name.replace(" ", "_"))
	r.sprite = G.stock.get_image(path)
	return r


class Buff:
	var unit
	var name
	var duration = 0
	var sprite


	func _init(punit, pdur):
		unit = punit
		duration = pdur
		on_start()


	func on_turn():
		if duration == 0:
			on_end()
			return false
		if duration > 0:
			duration -= 1
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
		unit.procedure.speed -= .3
	func on_end():
		unit.procedure.speed += .3
	func get_description():
		return super() + "Movement speed slowed by 3."


class Sleep extends Buff:
	func on_start():
		unit.alert = false
		if unit.health > 0:
			unit.animator.play("down")
			unit.action.force_set_next("sleep", 9999)
	func on_end():
		unit.alert = true
		if unit.health > 0:
			unit.action.delay = 0
	func get_description():
		return super() + "Wake when taking damage."


class Regeneration extends Buff:
	func on_turn():
		var max_hp = unit.data.get("health", 1)
		unit.health = min(unit.health + 1, max_hp)
		unit.show_healthbar()
		return super()
	func get_description():
		return super() + "Regenerate 1 health per second."


class Poison extends Buff:
	func on_turn():
		unit.take_hit(1)
		return super()
	func get_description():
		return super() + "Lose 1 health per second."


class Clarity extends Buff:
	func on_start():
		G.stock.make_particle(unit.get_head(), "clarity")
	func on_turn():
		var max_hp = unit.data.get("mana", 1)
		var inc = max(1, int(max_hp * 0.08))
		unit.mana = min(unit.mana + inc, max_hp)
		return super()
	func get_description():
		return super() + "Regenerate 8% mana per second."


class Invisibility extends Buff:
	var interrupted = false
	func on_start():
		unit.weapon.connect(on_interrupt)
		unit.hide()
	func on_end():
		unit.show()
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
		if unit == G.you:
			G.terrain.set_material_override(mat)
			G.player.get_node("View/Camera").far = 8 + unit.get_prof("psych") * 4
	func on_end():
		if unit == G.you:
			G.terrain.set_material_override(null)
			G.player.get_node("View/Camera").far = 4000
	func get_description():
		return super() + "Gain vision through walls. Vision distance scales with Psych."


class Nighteye extends Buff:
	func on_start():
		if unit == G.you:
			G.env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			G.env.environment.ambient_light_color = Color.GREEN
			G.env.environment.ambient_light_energy = 4.0
	func on_end():
		if unit == G.you:
			G.env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
	func get_description():
		return super() + "Gain vision through the darkness."


class Stoneskin extends Buff:
	func on_start():
		unit.defense += 5
	func on_end():
		unit.defense -= 5
	func get_description():
		return super() + "Negate incoming damage by 5."


class Corrosion extends Buff:
	func on_start():
		unit.defense -= 3
	func on_end():
		unit.defense += 3
	func get_description():
		return super() + "Increase all damage taken by 3."


class Daze extends Buff:
	func get_description():
		return super() + "Disables interation for the duration."


class Silence extends Buff:
	func get_description():
		return super() + "Disables abilities for the duration."


class Track extends Buff:
	func get_description():
		return super() + "Teleport to safety when downed."

