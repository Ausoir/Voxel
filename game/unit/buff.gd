static func get_buff(name):
	var r
	if name == "slow":
		r = Slow
	elif name == "sleep":
		r = Sleep
	elif name == "down":
		r = Down
	elif name == "regeneration":
		r = Regeneration
	elif name == "clarity":
		r = Clarity
	elif name == "invisible":
		r = Invisible
	elif name == "stoneskin":
		r = Stoneskin
	elif name == "corrosion":
		r = Corrosion
	elif name == "snare":
		r = Snare
	elif name == "daze":
		r = Daze
	elif name == "silence":
		r = Silence
	elif name == "poison":
		r = Poison
	elif name == "track":
		r = Track
	elif name == "glow":
		r = Glow
	elif name == "nighteye":
		r = Nighteye
	elif name == "vision":
		r = Vision
	elif name == "flight":
		r = Flight
	elif name == "lethality":
		r = Lethality
	elif name == "venomous":
		r = Venomous
	elif name == "morph":
		r = Morph
	elif name == "polymorph":
		r = Polymorph
	elif name == "invincible":
		r = Invincible
	elif name == "hunger":
		r = Hunger
	elif name == "full":
		r = Full
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


	func pre_save():
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


class Snare extends Buff:
	func on_start():
		_unit.procedure.speed -= 9
	func on_end():
		_unit.procedure.speed += 9
	func get_description():
		return super() + "Unable to move."


class Sleep extends Buff:
	func on_start():
		_unit.alert = false
		if _unit.health > 0:
			_unit.animator.play("down")
			_unit.action.force_set_next("sleep", 9999)
			_unit.procedure.speedmod = 0
		if _unit == G.you:
			G.you.camera.zoom_distance(2)
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
		if _unit == G.you:
			G.you.camera.zoom_distance(2)
	func on_end():
		if _unit.health > 0:
			_unit.action.delay = 0
		_unit.procedure.speedmod = 1
	func get_description():
		return super() + "Unable to act."


class Regeneration extends Buff:
	func on_turn():
		var max_hp = _unit.data.get("health", 1)
		if _unit.health < max_hp:
			_unit.show_healthbar()
		_unit.health = min(_unit.health + 1, max_hp)
		return super()
	func get_description():
		return super() + "Regenerate 1 health per second."


class Poison extends Buff:
	func on_turn():
		var dmg = max(1, _unit.data.health * .08)
		_unit.take_hit(dmg)
		return super()
	func get_description():
		return super() + "Lose 8% health per second."


class Clarity extends Buff:
	func on_start():
		G.stock.make_particle(_unit.get_head(), "clarity")
	func on_turn():
		var max_hp = _unit.data.get("mana", 1)
		var inc = max(1, int(max_hp * 0.1))
		_unit.mana = min(_unit.mana + inc, max_hp)
		return super()
	func get_description():
		return super() + "Regenerate 10% mana per second."


class Invisible extends Buff:
	var interrupted = false
	func on_start():
		_unit.weapon.connect(on_interrupt)
		_unit.special.connect(on_special)
		_unit.hide()
	func on_end():
		_unit.show()
	func get_description():
		return super() + "Become invisible."
	func on_interrupt(_type, _victim, _dmg):
		duration = 0
		interrupted = true
	func on_special(_type, _rate, _max=1):
		duration = 0
		interrupted = true
	func on_stack(new_dur):
		if !interrupted:
			duration = max(new_dur, duration)


class Vision extends Buff:
	var mat = preload("res://game/environment/xray.tres")
	func on_turn():
		if _unit == G.you:
			G.terrain.set_material_override(mat)
		return super()
	func on_end():
		if _unit == G.you:
			G.terrain.set_material_override(null)
	func get_description():
		return super() + "Gain vision through walls. Vision distance scales with Psych."


class Glow extends Buff:
	func on_start():
		var light = OmniLight3D.new()
		light.omni_range = 12
		light.set_name("Light")
		light.position.y = _unit.size.y / 2
		_unit.add_child(light)
	func on_end():
		var light = _unit.get_node("Light")
		light.queue_free()
		_unit.remove_child(light)
	func get_description():
		return super() + "Gain vision through the darkness."


class Nighteye extends Buff:
	func on_turn():
		if _unit == G.you:
			G.env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			G.env.environment.ambient_light_color = Color.GREEN
			G.env.environment.ambient_light_energy = 4.0
		return super()
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


class Lethality extends Buff:
	func on_start():
		_unit.data["damage"] = _unit.data.get("damage", 0) + 9
	func on_end():
		_unit.data.damage -= 9
	func get_description():
		return super() + "Next attack deals +9 damage."


class Venomous extends Buff:
	func on_start():
		_unit.data["inflict"] = _unit.data.get("inflict", []) + [["poison", 7]]
	func on_end():
		for i in _unit.data.inflict:
			if i[0] == "poison" and i[1] == 7:
				_unit.data.inflict.erase(i)
	func get_description():
		return super() + "Next attack inflicts 7s poison."


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


class Morph extends Buff:
	const FORMS = ["bunny", "squirrel", "bat", "rat"]
	var orig
	var orig_physics
	var new
	func pre_save():
		return false
	func get_form():
		var form = _unit.get("shape")
		if form == null:
			if _unit == G.you:
				var form_id = G.vars.seed % FORMS.size()
				form = FORMS[form_id]
			else:
				form = G.rng.pick(FORMS)
		return form
	func on_start():
		orig = _unit
		orig_physics = orig.physics_process
		orig.physics_process = orig._no_physics_process
		orig.hide()
		var form = get_form()
		new = G.stock.make_any_unit(G.stock, _unit.position, form)
		if _unit == G.you:
			G.player.set_unit(new)
		var morph = new.buffs.add("polymorph", duration)
		morph.orig = orig
		morph.orig_physics = orig_physics
		new.data.level = _unit.data.level
		for prof in new.proficiency.list.keys():
			var val = _unit.proficiency.list[prof]
			new.proficiency.increase(prof, val)
		morph.start_prof = new.proficiency.list.duplicate()
		var percentage = orig.health / orig.data.health
		new.health = int(round(max(1, new.data.health * percentage)))
		new.data.erase("loot")
		new.essence.append("polymorph")
		new.position = _unit.position
		new.action.set_next("idle", 1)
		new.action.show_progress = true
		new.procedure.speedmod = 0
		new.show_healthbar()
		orig.position.y -= 300
		duration = 0
	func get_description():
		return super() + "Transform."


class Polymorph extends Buff:
	var orig
	var orig_physics
	var start_prof
	func pre_save():
		return false
	func on_end():
		if orig != null:
			_unit.buffs._states.erase(name)
			_unit.buffs.clean(true)
			orig.physics_process = orig_physics
			orig.show()
			var new = _unit
			if _unit == G.you:
				G.player.set_unit(orig)
			orig.data.level = new.data.level
			for prof in new.proficiency.list.keys():
				var val = new.proficiency.list[prof] - start_prof[prof]
				orig.proficiency.increase(prof, val)
			if new.health <= 1:
				orig.health = 1
			else:
				var percentage = new.health / new.data.health
				orig.health = int(round(max(1, orig.data.health * percentage)))
			orig.position = new.position
			orig.action.set_next("idle", 1)
			orig.action.show_progress = true
			orig.procedure.speedmod = 0
			orig.show_healthbar()
			new.position.y -= 300
			new.hide()
			new.animator.set_speed_scale(100)
			new.die()
		elif _unit == G.you:
			G.ui.msg("It seems you are stuck in this form forever...")
	func get_description():
		return super() + "Currently transformed."


class Track extends Buff:
	func get_description():
		return super() + "Teleport to safety when near death."


class Invincible extends Buff:
	func get_description():
		return super() + "Invincible."


class Hunger extends Buff:
	func on_start():
		if _unit.buffs.has("full"):
			duration = 0
			_unit.buffs.set_duration("full", 0)
		_unit.procedure.speed -= .1
	func on_end():
		_unit.procedure.speed += .1
	func get_description():
		return super() + "Need to eat... -1 move speed and halved experience gain."


class Full extends Buff:
	func on_start():
		if _unit.buffs.has("hunger"):
			if !_unit.has_essence("ascetic"):
				duration = 0
			_unit.buffs.set_duration("hunger", 0)
	func get_description():
		return super() + "Don't worry about food for a while."

