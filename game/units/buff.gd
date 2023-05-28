static func make_buff(unit, name, dur):
	var r
	var undefined = false
	if name == "slow":
		r = Slow
	elif name == "regeneration":
		r = Regeneration
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
		duration -= 1
		if duration <= 0:
			on_end()
			return false
		return true


	func get_description():
		return name.capitalize() + "\n"


	func on_start():
		pass
	func on_end():
		pass


class Slow extends Buff:
	func on_start():
		unit.procedure.speed *= .25
	func on_end():
		unit.procedure.speed *= 4
	func get_description():
		return super() + "Movement speed slowed by 50%."


class Regeneration extends Buff:
	func on_turn():
		unit.health = min(unit.health + 1, unit.data.get("health", 1))
		return super()
	func get_description():
		return super() + "Movement speed slowed by 50%."

