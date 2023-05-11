static func make_buff(unit, name, dur):
	var r
	if name == "slow":
		r = Slow
	r = r.new(unit, dur)
	r.name = name
	return r


class Buff:
	var unit
	var name
	var duration = 0


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


	func on_start():
		pass
	func on_end():
		pass


class Slow extends Buff:
	func on_start():
		unit.procedure.speed *= .5
	func on_end():
		unit.procedure.speed *= 2

