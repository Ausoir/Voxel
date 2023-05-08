extends Node


var vars
@onready var faction = $Faction
@onready var unit = $Unit


func _ready():
	unit.equipment.add_slot("armor")
	unit.equipment.wear(G.stock.get_item("jacket"))
	unit.equipment.pickup(G.stock.get_item("test"))
	unit.equipment.pickup(G.stock.get_item("cleaver"))
	unit.equipment.pickup(G.stock.get_item("remover"))
	unit.equipment.pickup(G.stock.get_item("labcoat"))
	unit.equipment.set_held_index(0)
	$Interface.set_unit(unit)
	$Save.load_data()
	unit.on_mesh_set()
