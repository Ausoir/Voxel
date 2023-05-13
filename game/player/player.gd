extends Node


var vars
var unit
@onready var faction = $Faction


func _ready():
	var u = G.stock.make_humanoid(self, Vector3(), "janitor")
	set_unit(u)
	$Interface.set_unit(unit)
	$Save.load_data()
	unit.on_mesh_set()


func set_unit(p):
	G.you = p
	var addon
	if unit != null:
		addon = unit.get_node("Addon")
		unit.queue_free()
		remove_child(unit)
	else:
		addon = get_node("Addon")
		remove_child(addon)
	unit = p
	unit.set_name("Unit")
	unit.faction = 1
	unit.add_child(addon)
	$View.set_unit(unit)
	$Control.set_unit(unit)
	$View.zoom_distance(0)
	unit._box_mover.set_collision_mask(4)
	unit._box_mover.set_step_climbing_enabled(false)
