extends "./sentient.gd"


func perceive():
	return false


func on_attacked(_dmg):
	_from = _unit.get_head()
	_to = G.you.get_head()
	_unit.forward = _from.direction_to(_to)
	_dist = _from.distance_to(_to)
	super(_dmg)
