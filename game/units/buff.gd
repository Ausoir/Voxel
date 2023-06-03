static func make_buff(unit, name, dur):
	var r
	var undefined = false
	if name == "slow":
		r = Slow
	elif name == "regeneration":
		r = Regeneration
	elif name == "clarity":
		r = Clarity
	elif name == "invisibility":
		r = Invisibility
	elif name == "vision":
		r = Vision
	elif name == "stoneskin":
		r = Stoneskin
	elif name == "corrosion":
		r = Corrosion
	elif name == "daze":
		r = Daze
	elif name == "silence":
		r = Silence
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
		elif duration > 0:
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
		unit.procedure.speed -= .2
	func on_end():
		unit.procedure.speed += .2
	func get_description():
		return super() + "Movement speed slowed by 50%."


class Regeneration extends Buff:
	func on_turn():
		var max_hp = unit.data.get("health", 1)
		var inc = max(1, int(max_hp * 0.08))
		unit.health = min(unit.health + inc, max_hp)
		return super()
	func get_description():
		return super() + "Regenerate 8% health per second."


class Clarity extends Buff:
	func on_turn():
		if unit == G.you:
			G.vars.mana += 1
		return super()
	func get_description():
		return super() + "Regenerate 1 mana per second."


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
	func on_start():
		if unit == G.you:
			var viewer = G.player.get_node("VoxelViewer")
			viewer.set_requires_visuals(false)
	func on_end():
		if unit == G.you:
			var viewer = G.player.get_node("VoxelViewer")
			viewer.set_requires_visuals(true)
	func get_description():
		return super() + "Gain vision through walls."


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

