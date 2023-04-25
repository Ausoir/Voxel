extends Node


var vars
@onready var unit = $Unit


func _ready():
	unit.equipment.add_slot("armor")
	unit.equipment.wear(G.stock.get_item("jacket"))
	unit.equipment.pickup(G.stock.get_item("flashlight"))
	unit.equipment.pickup(G.stock.get_item("spawner"))
	unit.equipment.pickup(G.stock.get_item("placer"))
	unit.equipment.pickup(G.stock.get_item("remover"))
	$Interface.set_unit(unit)
	$Save.load_data()
	if vars == null:
		vars = {
			"seed": Time.get_unix_time_from_system()
		}
	G.rng.set_seed(vars.seed)
