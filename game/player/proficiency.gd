extends Node


var _unit
var unarmed := 3.0
var blade := 0.0
var blunt := 0.0
var spear := 0.0
var dagger := 0.0
var bow := 0.0
var firearm := 0.0
var wand := 0.0
var armor := 0.0
var dodge := 0.0
var psych := 0.0
var earth := 0.0


func set_unit(p):
	_unit = p
	_unit.attacked.connect(on_attacked)
	_unit.weapon.connect(on_attack)
	_unit.skills.special.connect(on_essence)


func get_description():
	var list = ["unarmed", "blade", "blunt", "spear", "dagger", "bow", "firearm", "wand", "armor", "dodge", "psych", "earth"]
	var r = ""
	for i in list:
		var val = get(i)
		if val != null and val > 0:
			var level = floor(val)
			var percent = val - level
			r += str("[color=#691]", i.to_upper(), "[/color] :  ", level, " [b](", percent," %)[/b]", "\n")
	return r


func check_req(prof, amount):
	var property = get(prof)
	if property != null:
		if property >= amount:
			return true
	G.ui.set_message(str("[", prof.capitalize(), "] skill not high enough! Requires ", amount, "."))
	return false


func increase(prof, amount):
	var property = get(prof)
	if property != null:
		var past_lvl = floor(property)
		property += amount
		var current_lvl = floor(property)
		if current_lvl != past_lvl:
			var msg = str("[",prof.capitalize(),"] skill now level ",current_lvl,"!")
			G.ui.set_message(msg)
		set(prof, property)


func on_attacked():
	increase("dodge", 0.01)


func on_attack(_type, _victim):
	increase(_type, 0.01)


func on_essence(_ess):
	increase(_ess, 0.01)

