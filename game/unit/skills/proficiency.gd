extends Node

var _unit
var list = {
	"unarmed": 0.0,
	"blade": 0.0,
	"blunt": 0.0,
	"spear": 0.0,
	"dagger": 0.0,
	"bow": 0.0,
	"firearm": 0.0,
	"ambush": 0.0,
	"staff": 0.0,
	"armor": 0.0,
	"dodge": 0.0,
	"aura": 0.0,
	"psych": 0.0,
	"earth": 0.0,
}


func unserialize(p):
	if p != null:
		for i in p.keys():
			list[i] = p[i]


func serialize():
	return list


func set_unit(p):
	_unit = p
	_unit.attacked.connect(on_attacked)
	_unit.weapon.connect(on_attack)
	_unit.special.connect(on_essence)
	_unit.critical.connect(on_ambush)
	var profs = _unit.data.get("proficiency", {})
	for key in profs.keys():
		set(key, profs[key])


func get_description():
	var r = ""
	for i in list.keys():
		var val = list[i]
		var level = floor(val)
		var percent = val - level
		r += str("[color=#691]", i.to_upper(), "[/color] :  ", level, " [b](", percent," %)[/b]", "\n")
	return r


func check_req(prof, amount):
	var property = list.get(prof)
	if property != null:
		if property >= amount:
			return true
	G.ui.set_message(str("[", prof.capitalize(), "] skill not high enough! Requires ", amount, "."))
	return false


func increase(prof, amount):
	var property = list.get(prof)
	if property != null:
		var past_lvl = floor(property)
		property += amount
		var current_lvl = floor(property)
		if current_lvl != past_lvl:
			on_level(prof)
			var msg = str("[",prof.capitalize(),"] skill now level ",current_lvl,"!")
			G.ui.set_message(msg)
		list[prof] = property


func on_level(prof):
	if prof == "armor":
		_unit.data.health += 5


func on_attacked(dmg):
	increase("armor", 0.01 * dmg)


func on_attack(_type, _victim, dmg):
	increase(_type, 0.01 * dmg)


func on_ambush(_victim):
	increase("ambush", 0.1)


func on_essence(_ess):
	increase(_ess, 0.04)

