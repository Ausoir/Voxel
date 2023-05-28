extends "./sentient.gd"


func get_attack_range():
	return _unit.data.get("range", 2)
